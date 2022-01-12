source ./installenv.sh
[ -z "$DEVICE" ] && echo 'Please set device' && exit 1

# Install needed packages, like linux and bootloader
installpkgs $ESSENTIALS
systemctl enable NetworkManager.service
systemctl enable reflector.service

# Timezone
ln -sf /usr/share/zoneinfo/Europe/Oslo /etc/localtime

# Hardwareclock
hwclock --systohc

# Set locale (by uncommenting the english)
sed -i 's/#en_US.UTF-8/en_US.UTF-8/g' /etc/locale.gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf
locale-gen

# Set hosts
echo "$HOSTNAME" > /etc/hostname
cat <<EOF > /etc/hosts
127.0.0.1        localhost
::1              localhost
127.0.1.1        $HOSTNAME
EOF

# Increase install cores (THIS IS WRONG TODO FIX! NEEDS TO BE SED)
# echo "ParalellDownloads = $CPUCORES" >> /etc/pacman.conf
# echo "MAKEFLAGS=\"-j$CPUCORES\"" >> /etc/makepkg.conf

# Make norwegian standard keymap
echo "KEYMAP=no-latin1" > /etc/vconsole.conf

# Make boot directory and mount boot partition
mkdir /boot/EFI
mount "${DEVICE}p1" /boot/EFI


if "$BTRFS"; then
    sed -i 's/MODULES=()/MODULES=(btrfs)/g' /etc/mkinitcpio.conf
    pacman -S --noconfirm btrfs-progs grub-btrfs
fi

installgrub

# Make password
echo "enter password for root"
passwd
echo "finally, exit, umount -a and reboot, then run archinstall-3"

