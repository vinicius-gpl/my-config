#!/bin/bash

if pgrep -x "swaync" >/dev/null; then
  killall "swaync"
else
  swaync
fi
