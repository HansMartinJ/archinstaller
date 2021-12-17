source ./installenv.sh
[ -z "$DEVICE" ] && echo 'Please set device' && exit 1

# Timezone
ln -sf /usr/share/zoneinfo/Europe/Oslo /etc/localtime
# Harwareclock
hwclock --systohc

# Install needed packages, like linux and bootloader
pacman -S --noconfirm \
    grub efibootmgr dosfstools openssh os-prober mtools \
    linux-zen linux-zen-headers \
    networkmanager neovim linux-firmware git \
    xdg-utils xdg-user-dirs

# Set locale (by uncommenting the english)
sed -i 's/#en_US.UTF-8/en_US.UTF-8/g' /etc/locale.gen
locale-gen

# Make boot directory and mount boot partition
mkdir /boot/EFI
mount "${DEVICE}p1" /boot/EFI

if "$BTRFS"; then
    pacman -S --noconfirm btrfs-progs
    sed -i 's/MODULES=()/MODULES=(btrfs)/g' /etc/mkinitcpio.conf
    # Reinstall linux-zen to trigger mkinitcpio cuz im lazy
    pacman -S --noconfirm linux-zen
fi

# Install grub on EFI
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
# Set grub locale and make config
cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
grub-mkconfig -o /boot/grub/grub.cfg

# Make password
echo "enter password for root"
passwd

echo "finally, exit, umount -a and reboot"
