####
## bash -c "$(curl -fsSL https://confect1on.com/nixos)"
## Use the above to easily run the installer. :)
####

#!/usr/bin/env bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="https://github.com/confect1ondev/nixos.git"
INSTALL_DIR="$HOME/nixos"

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   NixOS Configuration Auto-Installer   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo -e "${RED}Error: git is not installed${NC}"
    echo "Please install git first: nix-shell -p git"
    exit 1
fi

# Remove existing directory if it exists
if [ -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}Found existing installation directory at $INSTALL_DIR${NC}"
    read -p "Remove and re-clone? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Removing existing directory...${NC}"
        rm -rf "$INSTALL_DIR"
    else
        echo -e "${GREEN}Using existing directory${NC}"
    fi
fi

# Clone the repository
if [ ! -d "$INSTALL_DIR" ]; then
    echo -e "${BLUE}Cloning repository from $REPO_URL...${NC}"
    git clone "$REPO_URL" "$INSTALL_DIR"
    echo -e "${GREEN}✓ Repository cloned successfully${NC}"
    echo ""
else
    echo -e "${BLUE}Updating existing repository...${NC}"
    cd "$INSTALL_DIR"
    git pull
    echo -e "${GREEN}✓ Repository updated${NC}"
    echo ""
fi

# Change to the installation directory
cd "$INSTALL_DIR"

# Make install script executable
chmod +x install.sh

echo -e "${GREEN}✓ Setup complete!${NC}"
echo -e "${BLUE}Installation directory: $INSTALL_DIR${NC}"
echo ""
echo -e "${BLUE}Handing off to install script...${NC}"
echo -e "${YELLOW}You may be prompted for your sudo password${NC}"
echo ""

# Hand off to the install script
exec sudo ./install.sh
