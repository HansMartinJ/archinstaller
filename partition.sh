source ./installenv.sh
[ -z "$DEVICE" ] && echo "Please provide device" && exit 1
wipefs -a "$DEVICE"
# ALL SPACES ARE NECESSARY
gdisk "$DEVICE" <<EOF
n
1

+$BOOTSIZE
ef00
n
2

+$SWAPSIZE
8200
n
3


8300
p
w
Y
EOF
