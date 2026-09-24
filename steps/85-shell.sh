#!/bin/bash
# zsh plugin manager, fonts and default shell.
# shellcheck source=../lib/common.sh
source "$(dirname -- "${BASH_SOURCE[0]}")/../lib/common.sh"

log "antidote (~/sh/antidote, sourced by zshrc.common)"
if [ -d "$HOME/sh/antidote" ]; then
    info "already installed"
else
    mkdir -p "$HOME/sh"
    git clone --depth=1 https://github.com/mattmc3/antidote.git "$HOME/sh/antidote"
fi

FONT_DIR="$HOME/.local/share/fonts"
fonts_changed=0

log "Nerd Fonts"
for font in JetBrainsMono CascadiaCode Meslo; do
    dest="$FONT_DIR/$font"
    if [ -n "$(ls -A "$dest" 2>/dev/null)" ]; then
        info "already installed: $font"
        continue
    fi
    unzip_font() { mkdir -p "$dest" && unzip -o -q "$1" -d "$dest"; }
    with_download "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$font.zip" unzip_font
    fonts_changed=1
done

# Commercial/private fonts aren't in this repo; copy them from wherever you keep them.
log "Private fonts (ComicCode, Aglet, Dossier, Mainboard, Inter)"
if ls "$FONT_DIR"/ComicCode* >/dev/null 2>&1; then
    info "already installed"
else
    src="$(ask "Folder with your private font files (empty to skip)")"
    src="${src/#\~/$HOME}"
    if [ -n "$src" ] && [ -d "$src" ]; then
        mkdir -p "$FONT_DIR"
        find "$src" -maxdepth 1 -type f \( -iname '*.otf' -o -iname '*.ttf' \) -exec cp -v {} "$FONT_DIR/" \;
        fonts_changed=1
    else
        info "skipped"
    fi
fi
[ "$fonts_changed" -eq 1 ] && fc-cache -f "$FONT_DIR" >/dev/null

log "Default shell: zsh"
ZSH_BIN="$(command -v zsh)"
if [ "$(getent passwd "$(id -un)" | cut -d: -f7)" = "$ZSH_BIN" ]; then
    info "already zsh"
else
    $SUDO chsh -s "$ZSH_BIN" "$(id -un)"
fi
