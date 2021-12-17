source ./installenv.sh
[ -z "$DEVICE" ] && echo 'Please set device' && exit 1

timedatectl set-ntp true
#reflector --latest 10 --sort rate --save /etc/pacman.d/mirrorlist

"$BTRFS" && echo 'using btrfs'
read -p 'Setup done, press enter to continue'


# FORMATING PARTITIONS WITH FILE SYSTEMS
# Mounting /EFI happens in chroot
mkfs.fat -F32 "${DEVICE}p1"
mkswap "${DEVICE}p2"
swapon "${DEVICE}p2"

if "$BTRFS"; then
    mkfs.btrfs -f "${DEVICE}p3"
    mount "${DEVICE}p3" /mnt
    btrfs subvolume create /mnt/@
    btrfs subvolume create /mnt/@home
    btrfs subvolume create /mnt/@snapshots
    umount /mnt
    mount -o noatime,compress=no,space_cache=v2,subvol=@ \
        "${DEVICE}p3" /mnt
    mkdir -p /mnt/{boot,home,.snapshots}
    # Same options implicitly apply to these mounts
    mount -o subvol=@home "${DEVICE}p3" /mnt/home
    mount -o subvol=@snapshots "${DEVICE}p3" /mnt/.snapshots
else
    mkfs.ext4 "${DEVICE}p3"
    mkfs.ext4 "${DEVICE}p4"
    mount "${DEVICE}p3" /mnt
    mkdir /mnt/home && mount "${DEVICE}p4" /mnt/home
fi

read -p 'Mounted partitions, press enter to continue'

# INSTALLING BASE
pacstrap -i /mnt base base-devel
# GENERATE file system tab
genfstab -U -p /mnt >> /mnt/etc/fstab

cp installenv /mnt
cp archinstall-2.sh /mnt

# Moving into install
echo "First part completed, now do \"arch-chroot /mnt\" and \"curl next part\" "
