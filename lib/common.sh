# shellcheck shell=bash
# Shared helpers, sourced by setup.sh and every steps/*.sh script.

set -euo pipefail

ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." &>/dev/null && pwd)"
export ROOT

# Use sudo only when not already root.
SUDO=""
[ "$(id -u)" -ne 0 ] && SUDO="sudo"

log()  { printf '\n==> %s\n' "$*"; }
info() { printf '    %s\n' "$*"; }
warn() { printf '    WARN: %s\n' "$*" >&2; }

have() { command -v "$1" >/dev/null 2>&1; }

pkg_installed() {
    dpkg-query -W -f='${Status}' "$1" 2>/dev/null | grep -q "install ok installed"
}

# Print the entries of a packages/*.txt list: strips comments and blank lines.
read_list() {
    sed -e 's/#.*//' -e 's/[[:space:]]*$//' "$ROOT/packages/$1" | grep -v '^[[:space:]]*$' || true
}

# apt-get install only the packages that aren't installed yet.
apt_install() {
    local missing=() p
    for p in "$@"; do
        pkg_installed "$p" || missing+=("$p")
    done
    if [ "${#missing[@]}" -eq 0 ]; then
        info "already installed: $*"
        return
    fi
    info "installing: ${missing[*]}"
    $SUDO apt-get install -y "${missing[@]}"
}

# URL of the newest non-prerelease asset of a GitHub repo whose name matches $2
# (a jq regex). Looks back a few releases since some releases skip platforms.
gh_latest_asset() {
    curl -fsSL "https://api.github.com/repos/$1/releases?per_page=10" \
        | jq -r --arg re "$2" \
            '[.[] | select(.prerelease | not) | .assets[] | select(.name | test($re)) | .browser_download_url][0] // empty'
}

# Download $2 to a temp file and run the command in $3... with the file as last arg.
with_download() {
    local url="$1" tmp file rc=0
    shift
    tmp="$(mktemp -d)"
    file="$tmp/$(basename "${url%%\?*}")"
    if curl -fL --progress-bar -o "$file" "$url"; then
        "$@" "$file" || rc=$?
    else
        rc=$?
    fi
    rm -rf "$tmp"
    return "$rc"
}

# Prompts read from the terminal so they work even when stdin is redirected;
# with no terminal they return the default (skip).
ask() {  # ask "Question" [default] -> echoes the answer
    local reply=""
    { printf '    %s%s: ' "$1" "${2:+ [$2]}" >/dev/tty && read -r reply </dev/tty; } 2>/dev/null || reply=""
    printf '%s' "${reply:-${2:-}}"
}

confirm() {  # confirm "Question" -> 0 on yes (default no)
    local reply=""
    { printf '    %s [y/N] ' "$1" >/dev/tty && read -r reply </dev/tty; } 2>/dev/null || reply=""
    case "$reply" in [yY]|[yY][eE][sS]) return 0 ;; *) return 1 ;; esac
}

# True when the SSH key is registered with GitHub. (ssh -T always exits 1, so
# check its message rather than its status.)
github_ssh_ok() {
    local out
    out="$(ssh -o BatchMode=yes -o StrictHostKeyChecking=accept-new -o ConnectTimeout=10 -T git@github.com 2>&1 || true)"
    [[ "$out" == *"successfully authenticated"* ]]
}
