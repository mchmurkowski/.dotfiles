setxkbmap -layout pl -option caps:escape

xset r rate 400 30

while true
    do
        LOCALTIME=$(date +%H:%M)
        xsetroot -name " $LOCALTIME "
        sleep 30s
done &

exec dwm
