starship init fish | source

function starship_transient_prompt_func
    tput cuu1
    starship module character
end

function prompt_newline --on-event fish_postexec
    echo
end

set -Ux EDITOR helix

# Format man pages
set -x MANROFFOPT -c
set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"

## Environment setup
# Apply .profile: use this to put fish compatible .profile stuff in
if test -f ~/.fish_profile
    source ~/.fish_profile
end

# Add ~/.local/bin to PATH
if test -d ~/.local/bin
    if not contains -- ~/.local/bin $PATH
        set -p PATH ~/.local/bin
    end
end

# Add ~/.cargo/bin to PATH
if test -d ~/.cargo/bin
    if not contains -- ~/.cargo/bin $PATH
        set -p PATH ~/.cargo/bin
    end
end

# Add ~/.zig to PATH
if test -d ~/.zig
    if not contains -- ~/.zig $PATH
        set -p PATH ~/.zig
    end
end

# Cmake build shortcut
function cmake-run
    set exe_name (basename $PWD)
    cmake -B build && cmake --build build && ./build/bin/$exe_name
end

# Fish command history
function history
    builtin history --show-time='%F %T '
end

function backup --argument filename
    cp $filename $filename.bak
end

## Aliases
# Replace ls with eza
alias ls='eza -al --color=always --group-directories-first --icons' # preferred listing
alias la='eza -a --color=always --group-directories-first --icons' # all files and dirs
alias ll='eza -l --color=always --group-directories-first --icons' # long format
alias lt='eza -aT --color=always --group-directories-first --icons' # tree listing
alias l.="eza -a | grep -e '^\.'" # show only dotfiles

# Common use
alias clear "command clear; commandline -f clear-screen"
alias fixpacman "sudo rm /var/lib/pacman/db.lck"
alias tarnow "tar -acf "
alias untar "tar -zxvf "
alias wget "wget -c "
alias psmem "ps auxf | sort -nr -k 4"
alias psmem10 "ps auxf | sort -nr -k 4 | head -10"
alias grep "grep --color=auto"
alias fgrep "fgrep --color=auto"
alias egrep "egrep --color=auto"
alias hw "hwinfo --short" # Hardware Info
alias big "expac -H M '%m\t%n' | sort -h | nl" # Sort installed packages according to size
alias gitpkg "pacman -Q | grep -i "\-git" | wc -l" # List amount of -git packages
alias update "sudo pacman -Syu"
alias cleanup "sudo pacman -Rns (pacman -Qtdq)"
alias jctl "journalctl -p 3 -xb"
alias rip "expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"
alias grub-update "sudo grub-mkconfig -o /boot/grub/grub.cfg"
alias mirror "sudo cachyos-rate-mirrors" # Get fastest mirrors
alias ff fastfetch
# Helix commands
alias helix-binds "bat ~/.config/helix/helix-keybinds.md"

# Ironwail shortcut
function ironwail
    cd /mnt/gigadisk/Quake/Ironwail/
    prime-run ./ironwail
end

# Zoxide setup
zoxide init --cmd zd fish | source
alias cdd="cd -"
