#!/bin/bash
# Apps installed by vendor script, tarball or AppImage, in install order.
# shellcheck source=../lib/common.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../lib/common.sh"

SMARTGIT_VERSION="26_1_052"

log "Claude Code"
if [ -x "$HOME/.local/bin/claude" ]; then
    info "already installed"
else
    curl -fsSL https://claude.ai/install.sh | bash
fi

log "SmartGit (/opt/smartgit)"
if [ -x /opt/smartgit/bin/smartgit.sh ]; then
    info "already installed"
else
    extract_smartgit() { tar -xzf "$1" -C /opt; }
    $SUDO install -d -o "$(id -un)" -g "$(id -gn)" /opt/smartgit
    with_download "https://download.smartgit.dev/smartgit/smartgit-${SMARTGIT_VERSION}-linux-amd64.tar.gz" extract_smartgit
fi
if [ ! -f "$HOME/.local/share/applications/syntevo-smartgit.desktop" ]; then
    /opt/smartgit/bin/add-menuitem.sh
fi

log "Zed"
if [ -x "$HOME/.local/bin/zed" ]; then
    info "already installed"
else
    curl -fsSL https://zed.dev/install.sh | sh
fi

log "Bruno (~/AppImages)"
BRUNO="$HOME/AppImages/bruno.appimage"
if [ -x "$BRUNO" ]; then
    info "already installed"
else
    url="$(gh_latest_asset usebruno/bruno '^bruno_[0-9.]+_x86_64_linux\.AppImage$')"
    [ -n "$url" ] || { warn "no Bruno AppImage found in the latest releases"; exit 1; }
    mkdir -p "$HOME/AppImages/.icons"
    curl -fL --progress-bar -o "$BRUNO" "$url"
    chmod +x "$BRUNO"
fi
if [ ! -f "$HOME/.local/share/applications/bruno.desktop" ]; then
    # Same desktop entry Gear Lever created on the reference machine.
    tmp="$(mktemp -d)"
    (cd "$tmp" && "$BRUNO" --appimage-extract '*.png' >/dev/null 2>&1) || true
    icon="$(find "$tmp/squashfs-root" -maxdepth 1 -name '*.png' 2>/dev/null | head -n1)"
    [ -n "$icon" ] && install -D -m 0644 "$icon" "$HOME/AppImages/.icons/bruno"
    rm -rf "$tmp"
    mkdir -p "$HOME/.local/share/applications"
    cat >"$HOME/.local/share/applications/bruno.desktop" <<EOF
[Desktop Entry]
Type=Application
Name=Bruno
Comment=Opensource API Client for Exploring and Testing APIs
Icon=$HOME/AppImages/.icons/bruno
TryExec=$BRUNO
Exec=env DESKTOPINTEGRATION=1 $BRUNO --no-sandbox %U
Terminal=false
MimeType=x-scheme-handler/bruno;
Categories=Development;
StartupWMClass=Bruno
EOF
    info "created bruno.desktop"
fi

log "Google Cloud SDK (~/google-cloud-sdk)"
if [ -d "$HOME/google-cloud-sdk" ]; then
    info "already installed"
else
    # --disable-prompts leaves the rc files alone; zshrc already sources it.
    curl -fsSL https://sdk.cloud.google.com | bash -s -- --disable-prompts --install-dir="$HOME"
fi
