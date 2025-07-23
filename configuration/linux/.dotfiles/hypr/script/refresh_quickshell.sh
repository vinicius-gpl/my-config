#!/bin/bash

QSHELL_BIN="quickshell"

if pgrep -x "quickshell" >/dev/null; then
  pkill -x "quickshell"
else
  nohup $QSHELL_BIN >/dev/null 2>&1 &
fi
