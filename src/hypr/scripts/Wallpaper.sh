#!/bin/bash
set -x

LOCATION="~/Pictures/wallpapers/"

[ ! -d "$LOCATION" ] && mkdir -p "$LOCATION"

#set wallpaper
wallpaper=$(find {$LOCATION}-type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" \) | shuf -n 1)

# Set wallpaper with swww
swww-daemon &
swww img $wallpaper

# Generate colors with pywal
wal -i $wallpaper

# Start Waybar
waybar &
