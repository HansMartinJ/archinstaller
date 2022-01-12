source ./installenv.sh

installparu
"$SNAPPER" && installsnapper

installpkgs $CPU_DRIVER
installpkgs $GPU_DRIVER
installpkgs $FONTS
installpkgs $SYSTEM_PROGRAMS
installpkgs $PROGRAMS
installpkgs $DEVEL_PROGRAMS
installpkgs $XORG_PROGRAMS
installpkgs $WINDOW_MANAGER

installaur $AUR_PROGRAMS



cat << EOF > /etc/systemd/system/kmonad.service
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

