#!/bin/bash

FLAG="/tmp/headset-plugged.flag"

echo "Flag de headset criada" > /tmp/headset.log
logger "udev: Headset conectado, criando flag."
touch "$FLAG"
