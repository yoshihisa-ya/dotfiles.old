#!/bin/bash

if [ -f /usr/bin/rhythmbox-client ]; then
  echo -n ' '
  rhythmbox-client --no-start --print-playing --print-playing-format='NowPlaying: %tt/%at Singer: %ta'
fi
