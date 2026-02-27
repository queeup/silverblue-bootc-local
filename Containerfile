ARG FEDORA_VERSION=44

FROM quay.io/fedora-ostree-desktops/silverblue:${FEDORA_VERSION}

COPY system_files/ /

ARG USER_PACKAGES="hunspell-tr podman-compose thinkfan tuned-profiles-atomic"
RUN --mount=type=tmpfs,target=/var \
    --mount=type=tmpfs,target=/run/dnf \
    <<EORUN
dnf config-manager setopt '*.countme=0'

dnf --assumeyes remove \
    firefox \
    yelp yelp-libs yelp-xsl \
    totem-video-thumbnailer \
    gnome-user-docs gnome-shell-extension-* gnome-tour \
    fedora-bookmarks fedora-chromium-config* fedora-flathub-remote fedora-third-party fedora-workstation-repositories

dnf --repofrompath=rpmfusion-free,'http://download1.rpmfusion.org/free/fedora/releases/$releasever/Everything/$basearch/os/' \
    --repofrompath=rpmfusion-free-updates,'http://download1.rpmfusion.org/free/fedora/updates/$releasever/$basearch/' \
    --repofrompath=rpmfusion-nonfree,'http://download1.rpmfusion.org/nonfree/fedora/releases/$releasever/Everything/$basearch/os/' \
    --repofrompath=rpmfusion-nonfree-updates,'http://download1.rpmfusion.org/nonfree/fedora/updates/$releasever/$basearch/' \
    --setopt=*.gpgcheck=0 --assumeyes \
    do --allow-downgrade \
        --action=remove ffmpeg-free libavcodec-free libavdevice-free libavfilter-free libavformat-free libavutil-free libpostproc-free libswresample-free libswscale-free \
        --action=install ffmpegthumbnailer \
        --action=remove libva-intel-media-driver mesa-va-drivers \
        --action=install intel-media-driver

dnf --repofrompath=tailscale,'https://pkgs.tailscale.com/stable/fedora/$basearch' \
	--repo=tailscale --no-gpgchecks --assumeyes \
    install tailscale

dnf --repofrompath=vscode,'https://packages.microsoft.com/yumrepos/vscode' \
	--repo=vscode --no-gpgchecks --assumeyes \
    install code

dnf --repofrompath=antigravity,'https://us-central1-yum.pkg.dev/projects/antigravity-auto-updater-dev/antigravity-rpm' \
	--repo=antigravity --no-gpgchecks --assumeyes \
    install antigravity

dnf --repofrompath=terra,'https://repos.fyralabs.com/terra$releasever' \
    --no-gpgchecks --assumeyes \
	install bpftune starship ghostty

dnf --no-gpgchecks --assumeyes \
    install ${USER_PACKAGES}

mkdir /nix

curl --silent --location --remote-name --create-dirs --output-dir /etc/flatpak/remotes.d \
    https://dl.flathub.org/repo/flathub.flatpakrepo

systemctl mask --now rpm-ostree-countme.timer
systemctl mask --now flatpak-add-fedora-repos.service

awk '/^(enable|disable)/ {print $2}' /usr/lib/systemd/system-preset/98-user-custom.preset | \
    xargs -n1 -r systemctl preset
EORUN

RUN bootc container lint --no-truncate
