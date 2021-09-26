echo "starting setup..."

MIRRORS='## Norway
Server = http://mirror.archlinux.no/$repo/os/$arch
Server = https://mirror.archlinux.no/$repo/os/$arch
Server = http://archlinux.uib.no/$repo/os/$arch
Server = http://mirror.neuf.no/archlinux/$repo/os/$arch
Server = https://mirror.neuf.no/archlinux/$repo/os/$arch
Server = http://mirror.terrahost.no/linux/archlinux/$repo/os/$arch
'

PARTITION_DISK=''


loadkeys no
timedatectl set-ntp true
cat <(echo "$MIRRORS") /etc/pacman.d/mirrorlist > tmp
cat tmp > /etc/pacman.d/mirrorlist && rm tmp


if [ -z $PARTITION_DISK ]; then
    echo 'partitioned disk has not been selected, please enter disk: (e.g /dev/nvme0n1)'
    read $PARTITION_DISK || exit 1
fi


read -p 'Setup done, press enter to continue' || exit 1


# FORMATING PARTITIONS WITH FILE SYSTEMS
mkfs.fat -F32 "${PARTITION_DISK}p1"
mkswap "${PARTITION_DISK}p2"
mkfs.ext4 "${PARTITION_DISK}p3"
mkfs.ext4 "${PARTITION_DISK}p4"

read -p 'Made filesystem, press enter to continue' || exit 1

# MOUNTING and SWAPON
swapon "${PARTITION_DISK}p2"
mount "${PARTITION_DISK}p3" /mnt
mkdir /mnt/home && mount "${PARTITION_DISK}p4" /mnt/home

read -p 'Mounted partitions, press enter to continue' || exit 1

# INSTALLING BASE
pacstrap -i /mnt base
# GENERATE file system tab
genfstab -U -p /mnt >> /mnt/etc/fstab
# Moving into install
arch-chroot /mnt archinstall-inchroot.sh

read -p 'installed defaults and bootloader, press enter to reboot' || exit 1

unmount -a
reboot
