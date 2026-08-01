#!/bin/bash
set -ouex pipefail

### Install packages
## tailscale
dnf5 config-manager addrepo \
  --from-repofile=https://pkgs.tailscale.com/stable/fedora/tailscale.repo \
  --save-filename=tailscale \
  --overwrite
dnf5 install -y tailscale
rm -f /etc/yum.repos.d/tailscale.repo
systemctl enable tailscaled.service

## install ffmpeg and codecs from RPM Fusion
# see: https://rpmfusion.org/Howto/OSTree
dnf5 install -y \
  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
# Enable stable RPM Fusion repos; disable Rawhide if present
dnf5 config-manager setopt \
  rpmfusion-free.enabled=1 \
  rpmfusion-free-updates.enabled=1 \
  rpmfusion-nonfree.enabled=1 \
  rpmfusion-nonfree-updates.enabled=1
dnf5 config-manager setopt 'rpmfusion-*-rawhide.enabled=0' || :
# software codecs
dnf5 install -y \
  gstreamer1-plugin-libav \
  gstreamer1-plugins-bad-free-extras \
  gstreamer1-plugins-bad-freeworld \
  gstreamer1-plugins-ugly \
  gstreamer1-vaapi \
  ffmpeg \
  --allowerasing
dnf5 install -y intel-media-driver
# hardware codecs
# now disable RPM Fusion repos
dnf5 config-manager setopt 'rpmfusion-*.enabled=0'

# more packages
PACKAGES=(
    emacs
    fzf
    ripgrep
    fd-find
    bfs
    syncthing
    tmux
    fuse-sshfs # sshfs
    rclone # cloud storage and sync
    restic # backup tool
    wl-mirror # mirror screen/output
    NetworkManager-tui # nmtui
    trash-cli # delete by moving to trash
    fastfetch # system info
    wayvnc # VNC/remote desktop
    wlr-randr # check/manage display resolution, scale, refresh rate, etc.
    redhat-menus # (I think) provides XDG application menu files needed by Dolphin/KDE app picker
)
dnf5 install -y "${PACKAGES[@]}"

# clean caches
dnf5 clean all


### Set up install of Flatpak packages at boot
source /ctx/default-flatpaks.sh
FLATPAK_REMOTE_NAME="flathub"
FLATPAK_REMOTE_URL="https://dl.flathub.org/repo/flathub.flatpakrepo"
DISABLE_FEDORA_REMOTE="true"
FLATPAKS=(
    org.kde.okular
    io.mpv.Mpv
    org.libreoffice.LibreOffice
    com.interversehq.qView # image viewer
)
setup_default_flatpaks
