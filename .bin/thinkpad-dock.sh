#!/bin/sh
# wait for the dock state to change
sleep 0.5
export XAUTHORITY=/home/sial/.Xauthority 
export DISPLAY=:0
DOCKED=$(cat /sys/devices/platform/dock.2/docked)
case "$DOCKED" in
  "0")
    #undocked event - lets remove all connected outputs apart from LVDS
    for output in $(/usr/bin/xrandr -d :0.0 --verbose|grep " connected"|grep -v LVDS|awk '{print $1}')
    do
      su 'sial' -c '
      /usr/bin/xrandr -d :0.0 --output "$output" --off && \
      echo "awesome.restart()" | awesome-client && \
      kill -9 "$(pgrep xcape)" && \
      /usr/bin/setxkbmap -model pc104 -layout us,bg -variant ,phonetic && setxkbmap -option grp:shifts_toggle && \
      /usr/bin/xmodmap ~/.Xmodmap && \
      sleep 2 && \
      ~/.bin/xcape -e "0x1234=Return" \
      '
      
    done
    ;;
  "1")
    #docked event - sample will created extended desktop with DVI1 to the right of LVDS1
    su 'sial' -c '
    /usr/bin/xrandr -d :0.0 --output LVDS1 --auto --right-of DP2 && \
    /usr/bin/xrandr -d :0.0 --output DP2 --auto --primary && \
    echo "awesome.restart()" | awesome-client && \
    sleep 5 && \
    /usr/bin/setxkbmap -model pc104 -layout us,bg -variant ,phonetic && setxkbmap -option grp:shifts_toggle && \
    kill -9 "$(pgrep xcape)" && \
    /usr/bin/xmodmap ~/.Xmodmap && \
    sleep 2 && \
    ~/.bin/xcape -e "0x1234=Return" \
    '
    ;;
esac
exit 0
