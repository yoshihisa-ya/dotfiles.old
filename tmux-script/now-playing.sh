#!/bin/bash

if [ $OSTYPE == 'linux-gnu' ]; then
  if type "mpc" > /dev/null 2>&1; then
    echo -n ' '
    mpc -f "NowPlaying: %title% Singer: %artist%" current
  fi
fi

if [ $OSTYPE == 'darwin16' ]; then
  CURRENT_TRACK=$(osascript <<EOF
  tell application "iTunes"
    return "NowPlaying: " & name of current track & " Singer: " & artist of current track
  end tell
  EOF)

  echo $CURRENT_TRACK
fi


