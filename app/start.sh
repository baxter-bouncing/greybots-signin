#!/bin/bash

# Default to UTC if no TIMEZONE env variable is set
echo "Setting time zone to ${TIMEZONE=UTC}"
# This only works on Debian-based images
echo "${TIMEZONE}" > /etc/timezone
dpkg-reconfigure tzdata

# By default docker gives us 64MB of shared memory size but to display heavy
# pages we need more.
umount /dev/shm && mount -t tmpfs shm /dev/shm

# using local electron module instead of the global electron lets you
# easily control specific version dependency between your app and electron itself.
# the syntax below starts an X istance with ONLY our electronJS fired up,
# it saves you a LOT of resources avoiding full-desktops envs

rm /tmp/.X0-lock &>/dev/null || true
startx /usr/src/app/node_modules/electron/dist/electron /usr/src/app --enable-logging &

# Select display
export DISPLAY=:0

# Copy driver folder and change permissions
cp -r /usr/src/app/touchdriver/ /etc/opt/elo-usb
cd /etc/opt/elo-usb
chmod 777 *
chmod 444 *.txt
cp /etc/opt/elo-usb/99-elotouch.rules /etc/udev/rules.d

# Startup Driver
sh ./loadEloTouchUSB.sh
./eloautocalib --renew
