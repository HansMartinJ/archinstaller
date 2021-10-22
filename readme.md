# ARCH INSTALLER
READ THROUGH AND FILL IN BEFORE RUNNING


GET INTERNET WITH FOLLOWING COMMAND:
iwctl station "$WIFI-INTERFACE" connect "$WIFI-NAME" -P "$WIFI-PWD"

# YOU MUST PARTITION MANUALLY, GOOD DEFAULTS:
* PARTITION-DISK='/dev/nvme0n1'
* BOOT-SIZE='+1G'
* SWAP-SIZE='+20G'
* ROOT-SIZE='+50G'

# INSTALLER ASSUMES FOLLOWING STRUCTURE:
* 1: BOOT
* 2: SWAP
* 3: ROOT
* 4; HOME

 If disk=/dev/sda1, then the boot partition is named /dev/sda1p1


# PARTITION TUTORIAL:
* hit 'n', select (p) primary if promted
* choose default number
* choose default start
* choose a size (e.g. '+1G')
* WHEN ALL PARTITIONS HAVE BEEN MADE, HIT 'w'
