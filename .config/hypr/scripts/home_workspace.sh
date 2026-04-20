#!/bin/bash

open_home() {
    hyprctl dispatch exec "[workspace 10 silent]" "kitty --title pipes -- sh -c 'pipes.sh; sleep infinity'" > /dev/null 2>&1
    hyprctl dispatch exec "[workspace 10 silent]" "kitty --title clock -- tty-clock -c -s -C 6" > /dev/null 2>&1
    hyprctl dispatch exec "[workspace 10 silent]" "kitty --title cava -- cava" > /dev/null 2>&1
    hyprctl dispatch exec "[workspace 10 silent]" "kitty --title monitor -- btop" > /dev/null 2>&1
    hyprctl dispatch exec "[workspace 10 silent]" "kitty --title fastfetch -- sh -c 'fastfetch; sleep infinity'" > /dev/null 2>&1
    hyprctl dispatch exec "[workspace 10 silent]" "kitty --title cmatrix -- cmatrix" > /dev/null 2>&1
}

close_home() {
    for title in pipes clock cava monitor fastfetch cmatrix; do
        pid=$(hyprctl clients -j | jq -r ".[] | select(.title==\"${title}\") | .pid")
        [ -n "$pid" ] && kill "$pid" 2>/dev/null
    done
}

SOCKET_DIR=$(ls /run/user/1000/hypr/ | tail -1)
SOCKET="/run/user/1000/hypr/$SOCKET_DIR/.socket2.sock"

current=$(hyprctl activeworkspace -j | jq -r '.id')
[[ "$current" == "10" ]] && open_home

while true; do
    socat -U - UNIX-CONNECT:"$SOCKET" | while read -r line; do
        event=$(echo "$line" | cut -d'>' -f1)
        data=$(echo "$line" | cut -d'>' -f3-)

        if [[ "$event" == "workspace" && "$data" == "10" ]]; then
            open_home
        elif [[ "$event" == "workspace" && "$data" != "10" ]]; then
            close_home
        fi
    done
    sleep 1
done
