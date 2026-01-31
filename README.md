# Dotfiles
This repo contains the dotfiles for my system

## What Does it Do?
1. Update system
2. Install packages from official repos using pkglist.txt
3. Install paru if not already installed
4. Install packages from AUR using aurlist.txt
5. Install rust stable toolchain if not already installed
6. Stow dotfiles

## Installation
```sh
$ git clone https://github.com/HasChad/dotfiles ~/dotfiles
$ cd dotfiles
$ chmod +x install.sh
$ ./install.sh
```

## AppImage Apps
- [go-appimage](https://github.com/probonopd/go-appimage)
- [krita](https://krita.org/en)
- [blockbench](https://www.blockbench.net)


## Github SSH Key
**1. Generate an SSH key**
```sh
$ ssh-keygen -t ed25519 -C "your_email@example.com"
```
When prompted, you can just hit Enter to save it to the default location (~/.ssh/id_ed25519).  
Set a passphrase if you want extra security, or leave it blank

**2. Start the SSH agent and add your key**
```sh
$ eval "$(ssh-agent -s)"
$ ssh-add ~/.ssh/id_ed25519
```

**3. Copy your public key**
```sh
$ cat ~/.ssh/id_ed25519.pub
```
Copy the entire output

**4. Add the key to GitHub**
1. Go to GitHub.com -> Settings -> SSH and GPG keys
2. Click "New SSH key"
3. Paste your public key
4. Give it a title
5. Click "Add SSH key"

**5. Test the connection**
```sh
$ ssh -T git@github.com
```

**6. Use SSH URLs for your repos**
When cloning, use the SSH URL format:
```sh
$ git clone git@github.com:username/repo.git
```
If you already have repos cloned with HTTPS, switch them to SSH:
```sh
$ cd your-repo
$ git remote set-url origin git@github.com:username/repo.git
```

## Misc
For good laptop fan control ``nbfc-linux`` is a good option.  
"Acer Nitro AN515-51" config is good for now

## Useful Links
[Rose pine palette](https://rosepinetheme.com/palette/ingredients/)  
[Walls](https://github.com/dharmx/walls)  
[Rose pine wallpapers](https://github.com/p4rfait/rose-pine-wallpapers)  
[Awesome-hyperland](https://github.com/hyprland-community/awesome-hyprland)  
