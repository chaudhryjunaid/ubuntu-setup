#!/bin/bash
# Third-party apt repos and signing keys, copied verbatim from the reference
# machine (apt/files mirrors /). Existing files are never overwritten: several
# vendors' packages manage their own .sources file after install.
# shellcheck source=../lib/common.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../lib/common.sh"

log "Adding third-party apt repos"
changed=0
while IFS= read -r -d '' src; do
    dest="${src#"$ROOT/apt/files"}"
    if [ ! -e "$dest" ]; then
        $SUDO install -D -m 0644 "$src" "$dest"
        info "added $dest"
        changed=1
    elif ! cmp -s "$src" "$dest"; then
        info "kept existing $dest (differs from apt/files; run bin/inventory.sh to compare)"
    fi
done < <(find "$ROOT/apt/files" -type f -print0 | sort -z)

if [ "$changed" -eq 1 ]; then
    $SUDO apt-get update -y
else
    info "all repos already present"
fi
