starship init fish | source

function starship_transient_prompt_func
    tput cuu1
    starship module character
end

function prompt_newline --on-event fish_postexec
    echo
end

alias clear "command clear; commandline -f clear-screen"

# Format man pages
set -x MANROFFOPT -c
set -x MANPAGER "sh -c 'col -bx | bat -l man -p'"

# Set settings for https://github.com/franciscolourenco/done
set -U __done_min_cmd_duration 10000
set -U __done_notification_urgency_level low

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

# Add depot_tools to PATH
if test -d ~/Applications/depot_tools
    if not contains -- ~/Applications/depot_tools $PATH
        set -p PATH ~/Applications/depot_tools
    end
end

## Functions
# Functions needed for !! and !$ https://github.com/oh-my-fish/plugin-bang-bang
function __history_previous_command
    switch (commandline -t)
        case "!"
            commandline -t $history[1]
            commandline -f repaint
        case "*"
            commandline -i !
    end
end

function __history_previous_command_arguments
    switch (commandline -t)
        case "!"
            commandline -t ""
            commandline -f history-token-search-backward
        case "*"
            commandline -i '$'
    end
end

if [ "$fish_key_bindings" = fish_vi_key_bindings ]

    bind -Minsert ! __history_previous_command
    bind -Minsert '$' __history_previous_command_arguments
else
    bind ! __history_previous_command
    bind '$' __history_previous_command_arguments
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
alias fixpacman="sudo rm /var/lib/pacman/db.lck"
alias tarnow='tar -acf '
alias untar='tar -zxvf '
alias wget='wget -c '
alias psmem='ps auxf | sort -nr -k 4'
alias psmem10='ps auxf | sort -nr -k 4 | head -10'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias hw='hwinfo --short' # Hardware Info
alias big="expac -H M '%m\t%n' | sort -h | nl" # Sort installed packages according to size
alias gitpkg='pacman -Q | grep -i "\-git" | wc -l' # List amount of -git packages
alias update='sudo pacman -Syu'
alias cleanup='sudo pacman -Rns (pacman -Qtdq)'
alias jctl="journalctl -p 3 -xb"
alias rip="expac --timefmt='%Y-%m-%d %T' '%l\t%n %v' | sort | tail -200 | nl"
alias grub-update="sudo grub-mkconfig -o /boot/grub/grub.cfg"
alias mirror="sudo cachyos-rate-mirrors" # Get fastest mirrors

# Soar configs
fish_add_path /home/haschad/.local/bin
fish_add_path /home/haschad/.local/share/soar/bin

# Cmake build shortcut
function cmake-run
    set exe_name (basename $PWD)
    cmake -B build && cmake --build build && ./build/bin/$exe_name
end

# Helix commands
alias helix-binds="bat ~/dotfiles/config/.config/helix/helix-keybinds.md"

# Zig master
alias zigm="~/.zigm/zigm"

# Game aliases
alias ironwail="/mnt/gigadisk/Ironwail/ironwail-0.8.1-linux/ironwail -basedir /mnt/gigadisk/Ironwail/"
alias ase="/mnt/gigadisk/SteamLibrary/steamapps/common/Aseprite/aseprite"

# Zoxide setup
zoxide init --cmd zd fish | source
alias cdd="cd -"
