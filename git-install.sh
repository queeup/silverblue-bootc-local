#!/usr/bin/env bash

set -euox pipefail

# Check if script is run as root
# if [[ $EUID -ne 0 ]]; then
if [[ $(id -u) -ne 0 ]]; then
   echo "This script must be run as root (e.g., using sudo)."
   exit 1
fi

cd /tmp

rm -rf silverblue-bootc-local

git clone https://github.com/queeup/silverblue-bootc-local.git && cd "$(basename "$_" .git)"

rsync Containerfile /etc/system-image/
rsync -a system_files /etc/system-image/
rsync -a build_files/etc /

# run daemon-reload so systemd creates system-build.service
systemctl daemon-reload

# enable and start the timer schedule
systemctl enable --now system-build.timer

# trigger the build service to run immediately
systemctl start --verbose system-build.service
