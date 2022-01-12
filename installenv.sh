# CORE
DEVICE=''

HOSTNAME='arch'
CPUCORES=6

# PARTITIONING
BOOTSIZE="1G"
SWAPSIZE="10G"

# FS (else equals ext4)
BTRFS=true
SNAPPER=false

ESSENTIALS="\
grub
efibootmgr
dosfstools
openssh
os-prober
mtools
sudo
linux-zen
linux-zen-headers
linux-firmware
base-devel"

# cpu driver(s) change to xf86-video-amd for amd driver
CPU_DRIVERS="xf86-video-intel"

# gpu driver(s)
GPU_DRIVERS="\
nvidia
nvidia-dkms
nvidia-prime"

FONTS="\
noto-fonts
noto-fonts-cjk
noto-fonts-emoji
noto-fonts-extra"

SYSTEM_PROGRAMS="\
networkmanager
git
xdg-utils
man-db
zsh
wget
reflector
libnotify
pipewire
pipewire-pulse
pipewire-alsa"

AUR_PROGRAMS="\
kmonad-bin
julia-bin
micromamba-bin
nvim-packer-git
htop-vim
rmtrash"

DEVEL_PROGRAMS="\
automake
autoconf
rust
go
lua
zig
node
npm
jupyter-notebook"

PROGRAMS="\
fd
ripgrep
rsync
stow
tealdeer
thefuck
yt-dlp
ffmpeg
imagemagick
neofetch
kitty
neovim
firefox
qutebrowser"

XORG_PROGRAMS="
xorg-server
xorg-xinit
xorg-xclipboard
xorg-xinput
xclip
arandr
autorandr
xcompmgr
picom
dmenu
sxiv
zathura
zathura-pdf-mupdf
nitrogen
unclutter
dunst
autorandr"

WINDOW_MANAGER="awesome"

installpkgs() {
    echo $1 | pacman -S --noconfirm -
}

installaur() {
    echo $1 | paru -S --noconfirm -
}

installparu() {
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si
    cd ..
    rm -rf paru
}

installsnapper() {
    pacman -S --noconfirm snapper 
    paru -S --noconfirm snap-pac-grub
    umount /.snapshots
    rm -r /.snapshots
    snapper -c root create-config /
    btrfs subvolume delete /.snapshots
    mkdir /.snapshots
    mount -a
    chmod 750 /.snapshots
    sed -i 's/TIMELINE_LIMIT_HOURLY="10"/TIMELINE_LIMIT_HOURLY="5"'
    sed -i 's/TIMELINE_LIMIT_DAILY="10"/TIMELINE_LIMIT_DAILY="7"'
    sed -i 's/TIMELINE_LIMIT_WEEKLY="10"/TIMELINE_LIMIT_WEEKLY="0"'
    sed -i 's/TIMELINE_LIMIT_MONTHLY="10"/TIMELINE_LIMIT_MONTHLY="0"'
    sed -i 's/TIMELINE_LIMIT_YEARLY="10"/TIMELINE_LIMIT_YEARLY="0"'
    systemctl enable --now snapper-timeline.timer
    systemctl enable --now snapper-cleanup.timer
}

installgrub() {
    # Install grub on EFI
    grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
    # Set grub locale and make config
    cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
    sed -i "s/GRUB_TIMEOUT=5/GRUB_TIMEOUT=1/g" /etc/default/grub
    grub-mkconfig -o /boot/grub/grub.cfg
}
