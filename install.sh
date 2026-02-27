#!/usr/bin/env bash

# bash safety options
# -e exits on failure
# -u exits on unknown variables
# -o pipefail exits on failed pipe
set -euox pipefail

# Check if script is run as root
# if [[ $EUID -ne 0 ]]; then
if [[ $(id -u) -ne 0 ]]; then
   echo "This script must be run as root (e.g., using sudo)."
   exit 1
fi

BASE_URL="https://github.com/queeup/silverblue-bootc-local/raw/main"

# Files to download and their destination directories (in source:destination format)
FILES=(
    "Containerfile:/etc/system-image"
    "build_files/etc/containers/systemd/system.build:/etc/containers/systemd"
    "build_files/etc/systemd/system/system-build.timer:/etc/systemd/system"
)

echo "Downloading files from GitHub..."

for entry in "${FILES[@]}"; do
    # Split the 'entry' variable by ':' to separate source and destination
    src="${entry%%:*}"
    dest="${entry##*:}"

    curl --silent --show-error --fail --create-dirs --location \
        --output-dir "$dest" \
        --remote-name "${BASE_URL}/${src}"
done

echo "Files successfully downloaded and placed."
echo "Configuring systemd services..."

# run daemon-reload so systemd creates system-build.service
systemctl daemon-reload

# enable and start the timer schedule
systemctl enable --now system-build.timer

# trigger the build service to run immediately
systemctl start --verbose system-build.service

echo "Installation completed successfully!"