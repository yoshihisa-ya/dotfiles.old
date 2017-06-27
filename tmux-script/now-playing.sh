#!/bin/bash

if [ -f /usr/bin/rhythmbox-client ]; then
  echo -n ' '
  rhythmbox-client --no-start --print-playing --print-playing-format='NowPlaying: %tt Singer: %ta'
fi

CURRENT_TRACK=$(osascript <<EOF
tell application "iTunes"
  return "NowPlaying: " & name of current track & " Singer: " & artist of current track
end tell
EOF)

echo $CURRENT_TRACK
