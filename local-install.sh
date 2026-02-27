#!/usr/bin/env bash

# bash safety options
# -e exits on failure
# -u exits on unknown variables
# -o pipefail exits on failed pipe
set -euox pipefail

# regardless pwd when running, cd into this script's directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# move Containerfile to its destination
sudo mkdir -p /etc/system-image
sudo cp "$SCRIPT_DIR/Containerfile" /etc/system-image/

# move system.build to its destination
sudo mkdir -p /etc/containers/systemd
sudo cp "$SCRIPT_DIR/build_files/etc/containers/systemd/system.build" /etc/containers/systemd/

# move system-build.timer to its destination
sudo mkdir -p /etc/systemd/system
sudo cp "$SCRIPT_DIR/build_files/etc/systemd/system/system-build.timer" /etc/systemd/system/

sudo rsync -a "$SCRIPT_DIR/system_files" /etc/system-image/

# run daemon-reload so systemd creates system-build.service
sudo systemctl daemon-reload

# enable and start the timer schedule
sudo systemctl enable --now system-build.timer

# trigger the build service to run immediately
sudo systemctl start --verbose system-build.service