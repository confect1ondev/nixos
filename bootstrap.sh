#!/usr/bin/env bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Functions
print_error() {
    echo -e "${RED}ERROR: $1${NC}" >&2
}

print_success() {
    echo -e "${GREEN}SUCCESS: $1${NC}"
}

print_info() {
    echo -e "${BLUE}INFO: $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}WARNING: $1${NC}"
}

# Check requirements
check_requirements() {
    if [[ ! -f "bootstrap_agenix_key" ]] || [[ ! -f "bootstrap_agenix_key.pub" ]]; then
        print_warning "Bootstrap key pair not found, generating new key pair..."
        ssh-keygen -t ed25519 -f bootstrap_agenix_key -N '' -C 'agenix bootstrap key'
        print_success "Generated new bootstrap key pair"
    fi
    
    if [[ ! -f "secrets.nix" ]]; then
        print_error "secrets.nix not found"
        print_info "Please create secrets.nix first with content like:"
        print_info 'let'
        print_info '  bootstrapKey = builtins.readFile ./bootstrap_agenix_key.pub;'
        print_info 'in {'
        print_info '  "confect1on-password.age".publicKeys = [ bootstrapKey ];'
        print_info '}'
        exit 1
    fi
}

# Encrypt user password
encrypt_user_password() {
    print_info "User Password Encryption"
    print_info "========================"
    echo
    
    # Username is hardcoded
    USERNAME="confect1on"
    print_info "Encrypting password for user: $USERNAME"
    
    # Get password
    while true; do
        read -s -p "Enter password for $USERNAME: " PASSWORD
        echo
        
        if [[ -z "$PASSWORD" ]]; then
            print_error "Password cannot be empty"
            continue
        fi
        
        read -s -p "Confirm password: " PASSWORD_CONFIRM
        echo
        
        if [[ "$PASSWORD" == "$PASSWORD_CONFIRM" ]]; then
            if [[ ${#PASSWORD} -lt 8 ]]; then
                print_error "Password must be at least 8 characters long"
                continue
            fi
            break
        else
            print_error "Passwords do not match. Please try again."
        fi
    done
    
    # Generate password hash
    print_info "Generating password hash..."
    PASSWORD_HASH=$(echo -n "$PASSWORD" | mkpasswd -s -m sha-512)
    
    # Clear password from memory
    PASSWORD="$(head -c 100 /dev/urandom | base64)"
    PASSWORD_CONFIRM="$(head -c 100 /dev/urandom | base64)"
    
    # Create secrets directory
    mkdir -p secrets
    
    # Create temporary file with password hash
    TEMP_FILE=$(mktemp)
    echo -n "$PASSWORD_HASH" > "$TEMP_FILE"
    
    # Encrypt the password hash using age directly via nix
    print_info "Encrypting password hash..."
    OUTPUT_FILE="secrets/${USERNAME}-password.age"
    
    # Read the public key
    PUBLIC_KEY=$(cat bootstrap_agenix_key.pub | cut -d' ' -f1-2)
    
    # Use age from nixpkgs to encrypt
    if nix run nixpkgs#age -- -r "$PUBLIC_KEY" -o "$OUTPUT_FILE" < "$TEMP_FILE"; then
        print_success "Password encrypted successfully: $OUTPUT_FILE"
    else
        print_error "Failed to encrypt password"
        rm -f "$TEMP_FILE"
        exit 1
    fi
    
    # Clean up
    shred -u "$TEMP_FILE" || rm -f "$TEMP_FILE"
    
    # Clear password hash from memory
    PASSWORD_HASH="$(head -c 100 /dev/urandom | base64)"
}

# Main
main() {
    print_info "Password Encryption Script"
    print_info "=============================="
    echo
    
    check_requirements
    encrypt_user_password
    
    echo
    print_success "Password encryption completed!"
    print_info "The encrypted password file has been created in the secrets/ directory"
    print_info "Note:"
    print_info "1. Keep the bootstrap_agenix_key private key secure"
    print_info "2. Key will be automatically copied during installation"
}

# Run main
main "$@"