source ./installenv.sh
[ -z "$DEVICE" ] && echo 'Please set device' && exit 1

# Timezone
ln -sf /usr/share/zoneinfo/Europe/Oslo /etc/localtime
# Harwareclock
hwclock --systohc

# Install needed packages, like linux and bootloader
pacman -S --noconfirm \
    grub efibootmgr dosfstools openssh os-prober mtools \
    linux-zen linux-zen-headers linux-firmware  base-devel


# Set locale (by uncommenting the english)
sed -i 's/#en_US.UTF-8/en_US.UTF-8/g' /etc/locale.gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf
locale-gen

# Make norwegian standard keymap
echo "KEYMAP=no-latin1" > /etc/vconsole.conf

# Make boot directory and mount boot partition
mkdir /boot/EFI
mount "${DEVICE}p1" /boot/EFI

git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si
cd ..
rm -rf paru

if "$BTRFS"; then
    sed -i 's/MODULES=()/MODULES=(btrfs)/g' /etc/mkinitcpio.conf
    pacman -S --noconfirm btrfs-progs snapper grub-btrfs
    paru -S yay -S snap-pac-grub
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
fi

# Install grub on EFI
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
# Set grub locale and make config
cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
sed -i "s/GRUB_TIMEOUT=5/GRUB_TIMEOUT=1/g" /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg


# Download fitting drivers by yoursel if this is wrong
pacman -S xf86-video-intel nvidia

pacman -S --noconfirm \
    networkmanager git \
    xdg-utils man-db zsh xorg-server xorg-xinit \
    xorg-xclipboard xorg-xinput xclip \
    reflector ttf-liberation \
    kitty sxiv zathura zathura-pdf-mupdf nitrogen neovim \
    xcompmgr picom pipewire unclutter dunst libnotify \
    autorandr stack rust go node npm \
    firefox qutebrowser fd rg \
    ffmpeg yt-dlp imagemagick dmenu \
    pipewire pipewire-pulse pipewire-alsa



paru -S --noconfirm nvim-packer-git 
git clone https://github.com/kmonad/kmonad.git
cd kmonad
stack install
cd ..
rm -rf kmonad
cat << EOF > /etc/systemd/system
[Unit]
Description=kmonad keyboard config

[Service]
Restart=always
RestartSec=3
ExecStart=/usr/bin/kmonad /home/hans/.config/kmonad/config.kbd
Nice=-20

[Install]
WantedBy=default.target
EOF

systemctl enable NetworkManager.service
systemctl enable reflector.service

# Make password
echo "enter password for root"
passwd
echo "finally, exit, umount -a and reboot"
