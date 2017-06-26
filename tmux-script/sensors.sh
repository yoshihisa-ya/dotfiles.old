#!/bin/bash

if [ $OSTYPE == 'linux-gnu' ]; then
  echo -n ' '
  sensors | grep "Package id 0:" | cut -c 16-23
elif [ $OSTYPE == 'darwin16' ]; then
  echo -n ' '
  istats cpu temp | cut -b11-18 | tr '\n' ', '
  echo -n 'Battery: '
  istats battery charge | cut -b17-20
fi
