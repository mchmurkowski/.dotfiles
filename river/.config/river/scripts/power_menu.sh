echo -e "systemctl reboot\nsystemctl poweroff " | fuzzel --dmenu | xargs -I {} sh -c "{}"
