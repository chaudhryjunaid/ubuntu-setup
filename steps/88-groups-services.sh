#!/bin/bash
# Group memberships and services for Docker, virtualization and Tailscale.
# shellcheck source=../lib/common.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../lib/common.sh"

log "User groups"
for group in docker libvirt kvm; do
    if ! getent group "$group" >/dev/null; then
        warn "group $group does not exist"
    elif id -nG "$(id -un)" | tr ' ' '\n' | grep -qx "$group"; then
        info "already in $group"
    else
        $SUDO usermod -aG "$group" "$(id -un)"
        info "added to $group (takes effect after logging out and back in)"
    fi
done

log "Services"
for svc in docker libvirtd tailscaled; do
    if systemctl is-enabled --quiet "$svc" 2>/dev/null; then
        info "already enabled: $svc"
    else
        $SUDO systemctl enable --now "$svc"
    fi
done
