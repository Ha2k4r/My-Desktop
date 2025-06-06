#!/usr/bin/env bash
		# ~/.local/bin/launcher-toggle.sh

		LAUNCHER="rofi"

		if pgrep -x $LAUNCHER > /dev/null; then
  		pkill $LAUNCHER
		else
		# launch in background so Hyprland doesn’t block
		   $LAUNCHER -show drun &
		fi
