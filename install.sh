#!/bin/bash
set -euo pipefail # exit on error, undefined var, or failed pipe

# Configuration
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\e[32m'; PURPLE='\e[35m'; YELLOW='\e[33m'; RED='\e[31m'; NC='\e[0m'

# --- Helpers ---------------------------------------------
print_header()  { echo -e "\n${GREEN}--> $1 <--${NC}\n"; }
print_success() { echo -e "${PURPLE}--> $1 <--${NC}"; }
print_warning() { echo -e "${YELLOW}Warning: $1${NC}"; }
print_error()   { echo -e "${RED}Error: $1${NC}"; exit 1; }

# Returns 0 (yes) / 1 (no)
confirm_action() {
    echo -e "${YELLOW}$1${NC}"
    read -p "Continue? [y/N]: " -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

require_confirm_or_exit() {
    confirm_action "$1" || { echo "Aborted by user."; exit 0; }
}

# Counts non-empty, non-comment lines; never fails (grep -c exits 1 on zero matches)
count_packages() {
    if [[ -f "$1" ]]; then
        grep -c '^[[:space:]]*[^[:space:]#]' "$1" || true
    else
        echo 0
    fi
}

# Prints list contents with comments/blank lines stripped; never fails
package_list() {
    if [[ -f "$1" ]]; then
        grep '^[[:space:]]*[^[:space:]#]' "$1" || true
    fi
}

# --- Welcome -------------------------------------------------
PKG_COUNT=$(count_packages "$DOTFILES_DIR/pkglist.txt")
AUR_COUNT=$(count_packages "$DOTFILES_DIR/aurlist.txt")
FLATPAK_COUNT=$(count_packages "$DOTFILES_DIR/flatpaklist.txt")

echo -e "\n${PURPLE}=== Arch Linux Setup Script ===${NC}\n"
cat <<EOF
This script will:
  -> Update your system
  -> Install base development tools (git, base-devel, stow, flatpak)
  -> Install paru AUR helper (if needed)
  -> Install $PKG_COUNT packages from official repos
  -> Install $AUR_COUNT packages from AUR
  -> Install $FLATPAK_COUNT packages from Flathub
  -> Set up the Rust toolchain (if rustup is present)
  -> Apply dotfiles from: $DOTFILES_DIR
     (home configs -> ~, system configs -> /)

EOF

require_confirm_or_exit "This will modify your system and potentially overwrite existing configurations."

# --- System update & base tools
print_header "System update and installing base tools"
sudo pacman -Syu || print_error "System update failed"
sudo pacman -S --needed git base-devel stow flatpak || print_error "Failed to install base tools"

# --- Paru
if command -v paru &>/dev/null; then
    echo "paru is already installed, skipping..."
else
    print_header "Installing paru"
    git clone https://aur.archlinux.org/paru.git /tmp/paru \
        || print_error "Failed to clone paru repository"
    if ! (cd /tmp/paru && makepkg -si); then
        rm -rf /tmp/paru
        print_error "Failed to build and install paru"
    fi
    rm -rf /tmp/paru
fi

# --- Package installs
if [[ "$PKG_COUNT" -gt 0 ]]; then
    print_header "Installing $PKG_COUNT official packages"
    package_list "$DOTFILES_DIR/pkglist.txt" | sudo pacman -S --needed - \
        || print_error "Failed to install official packages"
else
    print_warning "pkglist.txt missing or empty, skipping"
fi

if [[ "$AUR_COUNT" -gt 0 ]]; then
    print_header "Installing $AUR_COUNT AUR packages"
    package_list "$DOTFILES_DIR/aurlist.txt" | paru -S --needed - \
        || print_error "Failed to install AUR packages"
else
    print_warning "aurlist.txt missing or empty, skipping"
fi

if [[ "$FLATPAK_COUNT" -gt 0 ]]; then
    print_header "Installing $FLATPAK_COUNT Flathub packages"
    flatpak remote-add --if-not-exists --system \
        flathub https://flathub.org/repo/flathub.flatpakrepo \
        || print_error "Failed to add Flathub remote"
    package_list "$DOTFILES_DIR/flatpaklist.txt" \
        | xargs flatpak install --system flathub \
        || print_error "Failed to install Flathub packages"
else
    print_warning "flatpaklist.txt missing or empty, skipping"
fi

# --- Rust
if command -v rustc &>/dev/null; then
    echo "Rust is already installed, skipping..."
elif command -v rustup &>/dev/null; then
    print_header "Setting up Rust toolchain"
    rustup default stable || print_error "Failed to install Rust stable toolchain"
    rustup component add rust-analyzer || print_error "Failed to install rust-analyzer"
else
    print_warning "rustup not found. Install it first with: sudo pacman -S rustup"
    require_confirm_or_exit "Continue without Rust?"
fi

# --- Stow
print_header "Applying dotfiles configuration"

[[ -d "$DOTFILES_DIR/home" ]]   || print_error "Stow target directory not found: $DOTFILES_DIR/home"
[[ -d "$DOTFILES_DIR/system" ]] || print_error "Stow target directory not found: $DOTFILES_DIR/system"

if confirm_action "Existing configs will be linked over. Continue?"; then
    echo "  Stowing: home -> $HOME"
    stow -d "$DOTFILES_DIR" -t "$HOME" home \
        || print_error "Failed to apply dotfiles for: home"
    echo "  Stowing: system -> /"
    sudo stow -d "$DOTFILES_DIR" -t / system \
        || print_error "Failed to apply dotfiles for: system"
else
    echo "Skipping dotfiles application."
fi

# --- Done
echo
print_success "SETUP COMPLETE!"

echo -e "${YELLOW}Consider rebooting to ensure all changes take effect.${NC}"
read -p "Reboot now? [y/N]: " -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "Rebooting in 3 seconds..."
    sleep 3
    sudo reboot
else
    echo "Remember to reboot when convenient!"
fi
