DEVICE=''
BTRFS=true
[ -z $DEVICE ] && echo "Please set device" && exit 1

# Timezone
ln -sf /usr/share/zoneinfo/Europe/Oslo /etc/localtime
# Harwareclock
hwclock --systohc

# Install needed packages, like linux and bootloader
pacman -S --noconfirm\
    grub efibootmgr dosfstools openssh os-prober mtools \
    linux-zen linux-zen-headers \
    networkmanager neovim linux-firmware git \
    xdg-utils xdg-user-dils

# Set locale (by uncommenting the english)
sed -i 's/#en_US.UTF-8/en_US.UTF-8/g' /etc/locale.gen
locale-gen

# Make boot directory and mount boot partition
mkdir /boot/EFI
mount "${BOOT_PARTITION}p1" /boot/EFI

[ "$BTRFS" ] && sed -i 's/MODULES=()/MODULES=(btrfs)/g' /etc/mkinitcpio.conf

# Install grub on EFI
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
# Set grub locale and make config
cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
grub-mkconfig -o /boot/grub/grub.cfg

# Make password
echo "enter password for root"
passwd
