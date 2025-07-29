#!/bin/bash

if pgrep -x "quickshell" >/dev/null; then
  pkill -x "quickshell"
else
  nohup quickshell >/dev/null 2>&1 &
fi
