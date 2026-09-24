#!/bin/bash
# Apps from the third-party repos (packages/apt-repo.txt).
# shellcheck source=../lib/common.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../lib/common.sh"

log "Installing apps from third-party repos"
while read -r -u 3 line; do
    # shellcheck disable=SC2086  # a line may hold several packages
    apt_install $line
done 3< <(read_list apt-repo.txt)
