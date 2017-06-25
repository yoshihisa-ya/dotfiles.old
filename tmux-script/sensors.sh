#!/bin/bash

if [ $OSTYPE == 'linux-gnu' ]; then
  echo -n ' '
  sensors | grep "Package id 0:" | cut -c 16-23
fi
