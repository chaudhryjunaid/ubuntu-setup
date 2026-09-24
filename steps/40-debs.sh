#!/bin/bash
# Apps only published as downloadable .debs (packages/debs.txt).
# shellcheck source=../lib/common.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../lib/common.sh"

install_deb_file() { $SUDO apt-get install -y "$1"; }

log "Installing downloaded .deb packages"
while read -r -u 3 pkg source; do
    if pkg_installed "$pkg"; then
        info "already installed: $pkg"
        continue
    fi
    case "$source" in
        gh:*)
            IFS=: read -r _ repo regex <<<"$source"
            url="$(gh_latest_asset "$repo" "$regex")"
            [ -n "$url" ] || { warn "no release asset matching $regex in $repo"; exit 1; }
            ;;
        *) url="$source" ;;
    esac
    info "installing $pkg from $url"
    with_download "$url" install_deb_file
done 3< <(read_list debs.txt)
