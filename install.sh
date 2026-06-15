#!/bin/bash
set -e # exit if any command fails

# Configuration
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
STOW_TARGETS="${STOW_TARGETS:-config/}" # you can add new folders with space or comma

# Colors for output
GREEN='\e[32m'
PURPLE='\e[35m'
YELLOW='\e[33m'
RED='\e[31m'
NC='\e[0m' # No Color

# Helper functions
print_header() {
    echo
    echo -e "${GREEN}--> $1 <--${NC}"
    echo
}

print_success() {
    echo -e "${PURPLE}--> $1 <--${NC}"
}

print_warning() {
    echo -e "${YELLOW}Warning: $1${NC}"
}

print_error() {
    echo -e "${RED}Error: $1${NC}"
    exit 1
}

confirm_action() {
    local message="$1"
    echo -e "${YELLOW}$message${NC}"
    read -p "Continue? [y/N]: " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborted by user."
        exit 0
    fi
}

count_packages() {
    local file="$1"
    if [[ -f "$file" ]]; then
        grep -c '^[[:space:]]*[^[:space:]]*[^[:space:]]' "$file" 2>/dev/null || echo "0"
    else
        echo "0"
    fi
}

# Welcome message and confirmation
echo
echo -e "${PURPLE}=== Arch Linux Setup Script ===${NC}"
echo
echo "This script will:"
echo "  • Update your system"
echo "  • Install base development tools"
echo "  • Install $(count_packages pkglist.txt) packages from official repos"
echo "  • Install paru AUR helper (if needed)"
echo "  • Install $(count_packages aurlist.txt) packages from AUR"
echo "  • Apply dotfiles from: $DOTFILES_DIR"
echo

confirm_action "This will modify your system and potentially overwrite existing configurations."

# Update system
print_header "System update and installing base tools"

if ! sudo pacman -Syu --noconfirm; then
    print_error "System update failed"
fi

if ! sudo pacman -S --noconfirm --needed git base-devel stow; then
    print_error "Failed to install base tools"
fi

# Install packages from official repos
if [[ -f pkglist.txt ]]; then
    pkg_count=$(count_packages pkglist.txt)
    print_header "Installing $pkg_count packages from official repositories"
    
    if ! sudo pacman -S --noconfirm --needed - < pkglist.txt; then
        print_error "Failed to install some packages from official repositories"
    fi
else
    print_warning "pkglist.txt not found, skipping official repo packages"
fi

# Install paru
if ! command -v paru &>/dev/null; then
    print_header "Installing Paru"
    
    if ! git clone https://aur.archlinux.org/paru.git /tmp/paru; then
        print_error "Failed to clone paru repository"
    fi
    
    if ! (cd /tmp/paru && makepkg -si --noconfirm); then
        print_error "Failed to build and install paru"
    fi
    
    rm -rf /tmp/paru
else
    echo
    echo "paru is already installed, skipping..."
fi

# Install packages from AUR
if [[ -f aurlist.txt ]]; then
    aur_count=$(count_packages aurlist.txt)
    print_header "Installing $aur_count packages from AUR"
    
    if ! paru -S --noconfirm --needed - < aurlist.txt; then
        print_error "Failed to install some AUR packages"
    fi
else
    print_warning "aurlist.txt not found, skipping AUR packages"
fi

# Setup Rust toolchain
if ! command -v rustc &>/dev/null; then
    print_header "Setting up Rust toolchain"

    if command -v rustup &>/dev/null; then
        echo "rustup found, installing stable toolchain..."

        if ! rustup default stable; then
            print_error "Failed to install Rust stable toolchain"
        fi

        if ! rustup component add rust-analyzer; then
            print_error "Failed to install rust-analyzer"
        fi
    else
        print_warning "rustup not found. Install it first with: sudo pacman -S rustup"
        confirm_action "Continue without Rust?"
    fi
else
    echo
    echo "Rust is already installed, skipping..."
fi

## STOW
print_header "Applying dotfiles configuration"

# Check if stow target exists
if [[ ! -d "$DOTFILES_DIR/$STOW_TARGETS" ]]; then
    print_error "Stow target directory not found: $DOTFILES_DIR/$STOW_TARGETS"
fi

# Convert space separated targets to array
IFS=' ,' read -ra TARGETS <<< "$STOW_TARGETS"

# Apply dotfiles
confirm_action "Stow may overwrite existing configuration files. Continue?"

echo "Applying stow targets: ${TARGETS[*]}"
for target in "${TARGETS[@]}"; do
    target="${target%/}"
    echo "  Stowing: $target"
    if ! stow -t ~ "$target"; then
        print_error "Failed to apply dotfiles for target: $target"
    fi
done

# Completion message
echo
print_success "SETUP COMPLETE!"
echo
echo "Summary:"
echo "  ✓ System updated"
echo "  ✓ Base tools installed"
echo "  ✓ $(count_packages pkglist.txt) official packages installed"
echo "  ✓ Paru ready"
echo "  ✓ $(count_packages aurlist.txt) AUR packages installed"
echo "  ✓ Rust and rust-analyzer installed"
echo "  ✓ Dotfiles applied"
echo
echo -e "${YELLOW}Consider rebooting to ensure all changes take effect.${NC}"
read -p "Reboot now? [y/N]: " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Rebooting in 3 seconds..."
    sleep 3
    sudo reboot
else
    echo "Remember to reboot when convenient!"
fi
