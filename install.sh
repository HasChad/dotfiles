#!/bin/bash
set -e # exit if any command fails

# Update system
echo
echo -e "\e[32m --> System update and installing base tools <-- \e[0m"
echo

sudo pacman -Syu --noconfirm
sudo pacman -S --noconfirm --needed git base-devel stow

# Install packages from official repos
if [[ -f pkglist.txt ]]; then
    echo
    echo -e "\e[32m --> Installing repo packages <-- \e[0m"
    echo

    sudo pacman -S --noconfirm --needed - < pkglist.txt
fi

# Install paru
if ! command -v paru &>/dev/null; then
    echo
    echo -e "\e[32m --> Installing paru <-- \e[0m"
    echo

    git clone https://aur.archlinux.org/paru.git /tmp/paru
    (cd /tmp/paru && makepkg -si --noconfirm)
    rm -rf /tmp/paru
fi

# Install packages from AUR
if [[ -f aurlist.txt ]]; then
    echo
    echo -e "\e[32m --> Installing AUR packages <-- \e[0m"
    echo

    paru -S --noconfirm --needed - < aurlist.txt
fi

# Apply dotfiles with stow
echo
echo -e "\e[32m --> Stowing dotfiles <-- \e[0m"
echo

cd ~/dotfiles
stow config/

echo
echo -e "\e[35m --> SETUP COMPLETE! <-- \e[0m"
echo
