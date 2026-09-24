#!/bin/bash
# Optional logins, then the steps that can't be automated.
# shellcheck source=../lib/common.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../lib/common.sh"

log "SSH key"
if ls "$HOME"/.ssh/id_* >/dev/null 2>&1; then
    info "already present"
elif confirm "Generate an ed25519 SSH key?"; then
    ssh-keygen -t ed25519 -C "$(id -un)@$(hostname)" -f "$HOME/.ssh/id_ed25519" </dev/tty
fi

log "GitHub CLI"
if gh auth status >/dev/null 2>&1; then
    info "already logged in"
elif confirm "Run 'gh auth login' now (can also upload your SSH key)?"; then
    gh auth login </dev/tty
fi

if git -C "$HOME/rcfiles" remote get-url origin 2>/dev/null | grep -q '^https://' \
    && github_ssh_ok; then
    git -C "$HOME/rcfiles" remote set-url origin git@github.com:chaudhryjunaid/rcfiles.git
    info "switched ~/rcfiles remote to SSH"
fi

log "Tailscale"
if tailscale status >/dev/null 2>&1; then
    info "already connected"
elif confirm "Run 'sudo tailscale up' now?"; then
    $SUDO tailscale up </dev/tty
fi

cat <<'NOTE'

Remaining manual steps:
  - Log out and back in so zsh, the new fonts and the docker/libvirt groups take effect.
  - Start Dropbox from the app menu and sign in (it downloads its daemon on first run).
  - Sign in to Chrome, Slack, Claude, ChatGPT, Zed, Obsidian, TablePlus, SmartGit.
  - gcloud auth login   (Google Cloud SDK)
  - Set the terminal font in kitty if it isn't picked up (e.g. "JetBrainsMono Nerd Font").
NOTE
