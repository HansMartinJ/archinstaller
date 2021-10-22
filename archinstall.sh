echo "starting setup..."
read -p 'Press enter to continue'

MIRRORS='## Norway
Server = http://mirror.archlinux.no/$repo/os/$arch
Server = https://mirror.archlinux.no/$repo/os/$arch
Server = http://archlinux.uib.no/$repo/os/$arch
Server = http://mirror.neuf.no/archlinux/$repo/os/$arch
Server = https://mirror.neuf.no/archlinux/$repo/os/$arch
Server = http://mirror.terrahost.no/linux/archlinux/$repo/os/$arch
'

PARTITION_DISK=''
[ -z $PARTITION_DISK ] && echo 'partitioned disk has not been selected, please edit this in file' && exit 1


timedatectl set-ntp true
cat <(echo "$MIRRORS") /etc/pacman.d/mirrorlist > tmp
cat tmp > /etc/pacman.d/mirrorlist && rm tmp
read -p 'Setup done, press enter to continue'


# FORMATING PARTITIONS WITH FILE SYSTEMS
mkfs.fat -F32 "${PARTITION_DISK}p1"
mkswap "${PARTITION_DISK}p2"
mkfs.ext4 "${PARTITION_DISK}p3"
mkfs.ext4 "${PARTITION_DISK}p4"
read -p 'Made filesystem, press enter to continue' 

# MOUNTING and SWAPON
swapon "${PARTITION_DISK}p2"
mount "${PARTITION_DISK}p3" /mnt
mkdir /mnt/home && mount "${PARTITION_DISK}p4" /mnt/home
read -p 'Mounted partitions, press enter to continue'

# INSTALLING BASE
pacstrap -i /mnt base base-devel
# GENERATE file system tab
genfstab -U -p /mnt >> /mnt/etc/fstab
# Moving into install

arch-chroot /mnt << EOF
[ -z $BOOT_PARTITION ] && echo "something went wrong" && exit 1

# Timezone
ln -sf /usr/share/zoneinfo/Europe/Oslo /etc/localtime
# Harwareclock
hwclock --systohc

# Install needed packages, like linux and bootloader
pacman -S --noconfirm grub efibootmgr dosfstools openssh os-prober mtools linux-headers linux-zen linux-zen-headers networkmanager neovim linux-firmware

# Set locale (by uncommenting the english)
sed -i 's/#en_US.UTF-8/en_US.UTF-8/g' /etc/locale.gen
locale-gen

# Make boot directory and mount boot partition
mkdir /boot/EFI
mount "$BOOT_PARTITION" /boot/EFI

# Install grub on EFI
grub-install --target=x86_64-efi --bootloader-id=grub_uefi --recheck
# Set grub locale and make config
cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
grub-mkconfig -o /boot/grub/grub.cfg

# Make password
echo "enter password for root"
passwd
EOF

read -p 'installed defaults and bootloader, press enter to reboot'

umount -a
reboot
