#!/usr/bin/env bash
set -euo pipefail

# Parse command line arguments
DRY_RUN=false
VERBOSE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --verbose|-v)
            VERBOSE=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --dry-run      Simulate installation with fake output"
            echo "  --verbose, -v  Show expanded output for all sections"
            echo "  --help, -h     Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Global variables
LUKS_PASSWORD=""

# ============================================================================
# Output Functions
# ============================================================================

print_error() {
    echo -e "${RED}✗ ERROR: $1${NC}" >&2
}

print_success() {
    echo -e "${GREEN}✓ SUCCESS: $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ INFO: $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ WARNING: $1${NC}"
}

print_prompt() {
    echo -ne "${CYAN}❯ $1${NC} "
}

print_step() {
    echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${CYAN}▶ $1${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_header() {
    local title="$1"
    local width=60
    local padding=$(( (width - ${#title} - 2) / 2 ))
    
    echo -e "\n${BOLD}${CYAN}┌$(printf '─%.0s' $(seq 1 $width))┐${NC}"
    echo -e "${BOLD}${CYAN}│$(printf ' %.0s' $(seq 1 $padding))${title}$(printf ' %.0s' $(seq 1 $((width - padding - ${#title}))))│${NC}"
    echo -e "${BOLD}${CYAN}└$(printf '─%.0s' $(seq 1 $width))┘${NC}\n"
}

# ============================================================================
# Host Selection Functions
# ============================================================================

# Get target disk from disko configuration
get_target_disk() {
    local host="$1"
    local disko_file="$SCRIPT_DIR/hosts/$host/disko.nix"
    
    if [[ ! -f "$disko_file" ]]; then
        echo "Unknown"
        return
    fi
    
    # Try to extract disk device from disko.nix
    # This is a simple grep - adjust pattern based on your disko config structure
    local disk=$(grep -oP 'device\s*=\s*"[^"]+"' "$disko_file" 2>/dev/null | head -1 | cut -d'"' -f2)
    
    if [[ -z "$disk" ]]; then
        # Try alternative pattern
        disk=$(grep -oP '/dev/[^\s;"]+' "$disko_file" 2>/dev/null | head -1)
    fi
    
    echo "${disk:-Unknown}"
}

# Check if host uses LUKS encryption
uses_luks() {
    local host="$1"
    local disko_file="$SCRIPT_DIR/hosts/$host/disko.nix"
    
    if [[ ! -f "$disko_file" ]]; then
        return 1
    fi
    
    # Check if the disko config contains LUKS
    if grep -q 'type = "luks"' "$disko_file" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Prompt for LUKS password
prompt_luks_password() {
    echo
    print_info "This system will use LUKS disk encryption"
    echo
    
    while true; do
        read -s -p "Enter LUKS encryption password: " LUKS_PASSWORD
        echo
        
        if [[ -z "$LUKS_PASSWORD" ]]; then
            print_error "LUKS password cannot be empty"
            continue
        fi
        
        if [[ ${#LUKS_PASSWORD} -lt 8 ]]; then
            print_error "LUKS password must be at least 8 characters long"
            continue
        fi
        
        read -s -p "Confirm LUKS password: " LUKS_PASSWORD_CONFIRM
        echo
        
        if [[ "$LUKS_PASSWORD" == "$LUKS_PASSWORD_CONFIRM" ]]; then
            # Clear confirmation from memory
            LUKS_PASSWORD_CONFIRM="$(head -c 100 /dev/urandom | base64)"
            print_success "LUKS password set"
            break
        else
            print_error "Passwords do not match. Please try again."
            # Clear passwords
            LUKS_PASSWORD=""
            LUKS_PASSWORD_CONFIRM=""
        fi
    done
}

select_host() {
    local hosts=()
    
    # Find available hosts
    for host in "$SCRIPT_DIR"/hosts/*/; do
        if [[ -d "$host" ]]; then
            hosts+=("$(basename "$host")")
        fi
    done
    
    if [[ ${#hosts[@]} -eq 0 ]]; then
        print_error "No host configurations found in hosts/"
        exit 1
    fi
    
    # If only one host, use it
    if [[ ${#hosts[@]} -eq 1 ]]; then
        HOST="${hosts[0]}"
        print_info "Using host: $HOST"
        return
    fi
    
    # Multiple hosts, let user choose
    print_info "Available hosts:"
    echo
    for i in "${!hosts[@]}"; do
        echo -e "  ${CYAN}$((i+1)))${NC} ${hosts[$i]}"
    done
    echo
    
    while true; do
        print_prompt "Select host (1-${#hosts[@]}):"
        read selection
        
        if [[ "$selection" =~ ^[0-9]+$ ]] && [[ $selection -ge 1 ]] && [[ $selection -le ${#hosts[@]} ]]; then
            HOST="${hosts[$((selection-1))]}"
            print_success "Selected host: $HOST"
            break
        else
            print_error "Invalid selection. Please enter a number between 1 and ${#hosts[@]}"
        fi
    done
}

# ============================================================================
# Installation Functions
# ============================================================================

check_requirements() {
    print_step "Checking Requirements"
    
    # Check if running as root
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root"
        print_info "Please run: sudo ./install.sh"
        exit 1
    fi
    
    # Check if host configuration exists
    if [[ ! -d "$SCRIPT_DIR/hosts/$HOST" ]]; then
        print_error "Host configuration not found: $HOST"
        exit 1
    fi
    
    print_success "All requirements met"
}

format_disks() {
    print_step "Formatting Disks with Disko"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        TARGET_DISK=$(get_target_disk "$HOST")
        print_info "[DRY RUN] Would format disks for host: $HOST"
        print_info "[DRY RUN] Target disk: ${TARGET_DISK:-/dev/nvme0n1 (example)}"
        if uses_luks "$HOST"; then
            print_info "[DRY RUN] Would use LUKS encryption"
        fi
        print_info "[DRY RUN] Creating GPT partition table..."
        print_info "[DRY RUN] Creating EFI partition (512MB)..."
        print_info "[DRY RUN] Creating root partition (remaining space)..."
        print_info "[DRY RUN] Formatting partitions..."
        print_info "[DRY RUN] Mounting filesystems..."
        print_success "Disk formatting completed"
        return 0
    fi
    
    # Set up LUKS password if needed
    if uses_luks "$HOST" && [[ -n "$LUKS_PASSWORD" ]]; then
        # Create a temporary file for the LUKS password
        LUKS_KEY_FILE=$(mktemp)
        echo -n "$LUKS_PASSWORD" > "$LUKS_KEY_FILE"
        export LUKS_KEY_FILE
        
        # Run disko with the password file
        if nix --experimental-features "nix-command flakes" \
            run github:nix-community/disko -- \
            --mode disko \
            --flake "${SCRIPT_DIR}#${HOST}"; then
            print_success "Disk formatting completed"
        else
            print_error "Disk formatting failed"
            # Clean up
            shred -u "$LUKS_KEY_FILE" 2>/dev/null || rm -f "$LUKS_KEY_FILE"
            unset LUKS_KEY_FILE
            exit 1
        fi
        
        # Clean up the password file
        shred -u "$LUKS_KEY_FILE" 2>/dev/null || rm -f "$LUKS_KEY_FILE"
        unset LUKS_KEY_FILE
    else
        # No LUKS, run disko normally
        if nix --experimental-features "nix-command flakes" \
            run github:nix-community/disko -- \
            --mode disko \
            --flake "${SCRIPT_DIR}#${HOST}"; then
            print_success "Disk formatting completed"
        else
            print_error "Disk formatting failed"
            exit 1
        fi
    fi
}

install_nixos() {
    print_step "Installing NixOS"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "[DRY RUN] Installing NixOS for host: $HOST"
        print_info "[DRY RUN] Downloading packages..."
        print_info "[DRY RUN] Building configuration..."
        print_info "[DRY RUN] Installing bootloader..."
        print_info "[DRY RUN] Setting up users and groups..."
        print_info "[DRY RUN] Configuring system services..."
        print_info "[DRY RUN] Running activation scripts..."
        print_success "NixOS installation completed"
        return 0
    fi
    
    if nixos-install --flake "${SCRIPT_DIR}#${HOST}" --no-root-passwd; then
        print_success "NixOS installation completed"
    else
        print_error "NixOS installation failed"
        exit 1
    fi
}

copy_configuration() {
    print_step "Copying Configuration to Installed System"
    
    # Extract username from Nix configuration
    local TARGET_USER=""
    
    # Try to get username from common.nix default value
    if [[ -f "$SCRIPT_DIR/modules/common.nix" ]]; then
        TARGET_USER=$(grep -A2 'username = lib.mkOption' "$SCRIPT_DIR/modules/common.nix" | \
                      grep 'default = ' | \
                      sed 's/.*default = "\([^"]*\)".*/\1/' | \
                      head -1)
    fi
    
    # Fallback to confect1on if extraction failed
    if [[ -z "$TARGET_USER" ]]; then
        TARGET_USER="confect1on"
        print_warning "Could not extract username from config, using default: $TARGET_USER"
    else
        print_info "Using username from config: $TARGET_USER"
    fi
    
    local TARGET_HOME="/mnt/home/$TARGET_USER"
    local TARGET_DEV_DIR="$TARGET_HOME/nixos-dev"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_info "[DRY RUN] Creating $TARGET_DEV_DIR directory..."
        print_info "[DRY RUN] Copying configuration files..."
        print_info "[DRY RUN] Source: $SCRIPT_DIR/"
        print_info "[DRY RUN] Destination: $TARGET_DEV_DIR/"
        print_info "[DRY RUN] Files to copy: $(find "$SCRIPT_DIR" -type f 2>/dev/null | wc -l || echo "247") files"
        print_info "[DRY RUN] Setting ownership to $TARGET_USER:users..."
        print_info "[DRY RUN] Creating /mnt/etc/nixos as minimal flake directory..."
        print_success "Configuration copied successfully"
        return 0
    fi
    
    # Check if /mnt exists
    if [[ ! -d /mnt ]]; then
        print_error "/mnt directory not found. Installation may have failed."
        exit 1
    fi
    
    # Create user's nixos-dev directory
    mkdir -p "$TARGET_DEV_DIR" || {
        print_error "Failed to create $TARGET_DEV_DIR directory"
        exit 1
    }
    
    # Copy with rsync to user's dev directory
    print_info "Copying configuration files to user's nixos-dev..."
    if rsync -av --info=progress2 "${SCRIPT_DIR}/" "$TARGET_DEV_DIR/"; then
        print_success "Configuration copied to $TARGET_DEV_DIR"
    else
        print_error "Failed to copy configuration files"
        exit 1
    fi
    
    # Set ownership to the target user
    chown -R 1000:100 "$TARGET_DEV_DIR" || {
        print_error "Failed to set ownership on configuration files"
        exit 1
    }
    
    # Create minimal /etc/nixos with just a flake.nix pointing to the user's config
    mkdir -p /mnt/etc/nixos || {
        print_error "Failed to create /mnt/etc/nixos directory"
        exit 1
    }
    
    # Create a simple flake.nix that imports from the user's directory
    cat > /mnt/etc/nixos/flake.nix << EOF
{
  description = "NixOS configuration";
  
  outputs = { ... }@inputs: {
    nixosConfigurations = (import /home/$TARGET_USER/nixos-dev/flake.nix).outputs inputs;
  };
}
EOF
    
    chown -R root:root /mnt/etc/nixos || {
        print_error "Failed to set ownership on /etc/nixos"
        exit 1
    }
    
    # Also copy to current system's user directory if it exists
    if [[ -d "/home/$TARGET_USER" ]]; then
        print_info "Copying configuration to current user's directory..."
        mkdir -p "/home/$TARGET_USER/nixos-dev"
        rsync -av "${SCRIPT_DIR}/" "/home/$TARGET_USER/nixos-dev/" || print_warning "Failed to copy to current system"
        chown -R "$TARGET_USER:users" "/home/$TARGET_USER/nixos-dev" || print_warning "Failed to set ownership on current system"
    fi
}

# ============================================================================
# Main Function
# ============================================================================

main() {
    print_header "conf1's Installation Script"
    
    # Extract username for password warning
    local CONFIG_USER=""
    if [[ -f "$SCRIPT_DIR/modules/common.nix" ]]; then
        CONFIG_USER=$(grep -A2 'username = lib.mkOption' "$SCRIPT_DIR/modules/common.nix" | \
                      grep 'default = ' | \
                      sed 's/.*default = "\([^"]*\)".*/\1/' | \
                      head -1)
    fi
    CONFIG_USER="${CONFIG_USER:-confect1on}"
    
    # Show default password info
    print_warning "DEFAULT PASSWORD INFORMATION"
    print_info "The default password for user '$CONFIG_USER' is: changeme"
    print_info "You MUST change this password after first login!"
    print_info "The system will show warnings until you change it."
    echo
    
    # Select host
    print_step "Host Selection"
    select_host
    
    # Check requirements (skip for dry run)
    if [[ "$DRY_RUN" != "true" ]]; then
        check_requirements
    else
        print_step "Requirements Check"
        print_info "[DRY RUN] Skipping requirement checks"
        print_success "All requirements met (simulated)"
    fi
    
    # Check if LUKS is needed and prompt for password
    if uses_luks "$HOST"; then
        if [[ "$DRY_RUN" != "true" ]]; then
            prompt_luks_password
        else
            print_info "[DRY RUN] Would prompt for LUKS password"
            LUKS_PASSWORD="dryrun-password"
        fi
    fi
    
    # Show installation summary
    print_step "Installation Summary"
    
    # Get target disk
    TARGET_DISK=$(get_target_disk "$HOST")
    
    # Extract username for summary
    local CONFIG_USER=""
    if [[ -f "$SCRIPT_DIR/modules/common.nix" ]]; then
        CONFIG_USER=$(grep -A2 'username = lib.mkOption' "$SCRIPT_DIR/modules/common.nix" | \
                      grep 'default = ' | \
                      sed 's/.*default = "\([^"]*\)".*/\1/' | \
                      head -1)
    fi
    CONFIG_USER="${CONFIG_USER:-confect1on}"
    
    echo -e "  ${BOLD}Host:${NC} $HOST"
    echo -e "  ${BOLD}Config:${NC} $SCRIPT_DIR"
    echo -e "  ${BOLD}Target:${NC} /mnt/home/$CONFIG_USER/nixos-dev"
    echo -e "  ${BOLD}User:${NC} $CONFIG_USER"
    echo -e "  ${BOLD}Disk:${NC} ${TARGET_DISK}"
    echo -e "  ${BOLD}Mode:${NC} $([ "$DRY_RUN" == "true" ] && echo "DRY RUN" || echo "LIVE")"
    
    if [[ "$TARGET_DISK" != "Unknown" ]] && [[ "$DRY_RUN" != "true" ]]; then
        echo
        print_warning "This will COMPLETELY ERASE: $TARGET_DISK"
    fi
    echo
    
    if [[ "$DRY_RUN" != "true" ]]; then
        print_prompt "Proceed with installation? (yes/no):"
        read proceed
        
        if [[ "$proceed" != "yes" ]]; then
            print_info "Installation cancelled"
            exit 0
        fi
    else
        print_info "[DRY RUN] Proceeding with simulated installation"
    fi
    
    # Run installation steps
    format_disks
    install_nixos
    copy_configuration
    
    # Final message
    print_header "Installation Complete!"
    
    # Clear LUKS password from memory
    if [[ -n "$LUKS_PASSWORD" ]]; then
        LUKS_PASSWORD="$(head -c 100 /dev/urandom | base64)"
    fi
    
    if [[ "$DRY_RUN" == "true" ]]; then
        print_success "[DRY RUN] Installation simulation completed successfully"
        print_info "This was a dry run - no actual changes were made"
    else
        print_success "NixOS has been successfully installed"
        print_info "You can now reboot into your new system"
        print_info "Run: reboot"
    fi
}

# ============================================================================
# Entry Point
# ============================================================================

main "$@"