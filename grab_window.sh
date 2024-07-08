#!/usr/bin/env bash

if [[ ! $(pidof wofi) ]]; then
    ADDRESS="$( hyprctl clients -j |  wofi  --style  ~/.config/wofi/style.css --show wg.so )"
    if [ -n "$ADDRESS" ]; then
        hyprctl dispatch movetoworkspace $( hyprctl activeworkspace -j | jq .id ),address:"$ADDRESS"
    fi    
else
    pkill wofi
fi

