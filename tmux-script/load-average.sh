#!/bin/bash

if [ $OSTYPE == 'linux-gnu' ]; then
  echo -n ' '
  cat /proc/loadavg | cut -d " " -f 1-3
elif [ $OSTYPE == 'darwin16' ]; then
  echo -n ' '
  uptime | awk '{print $(NF-2),$(NF-1),$NF}'
fi
