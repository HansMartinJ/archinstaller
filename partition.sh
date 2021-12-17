[ -z "$1" ] && echo "Please provide device" && exit 1
wipefs -a "$1"
gdisk "$1" <<EOF
n
1

+1G
ef00
EOF
