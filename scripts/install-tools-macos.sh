#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OH_MY_ZSH_DIR="$HOME/.oh-my-zsh"
ZSH_CUSTOM_DIR="${ZSH_CUSTOM:-$OH_MY_ZSH_DIR/custom}"
TPM_DIR="$HOME/.tmux/plugins/tpm"

log() {
  printf '[dotfiles] %s\n' "$*"
}

clone_or_update() {
  local repo="$1"
  local target="$2"

  if [[ -d "$target/.git" ]]; then
    log "updating $(basename "$target")"
    git -C "$target" pull --ff-only
    return
  fi

  log "cloning $(basename "$target")"
  git clone "$repo" "$target"
}

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "[dotfiles] warning: this script only supports macOS" >&2
  exit 1
fi

if ! command -v brew >/dev/null 2>&1; then
  echo "[dotfiles] Homebrew is required. Install it first: https://brew.sh/" >&2
  exit 1
fi

mkdir -p "$HOME/.nvm"
brew bundle --file "$REPO_ROOT/Brewfile"

if [[ ! -d "$OH_MY_ZSH_DIR" ]]; then
  log "installing oh-my-zsh"
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" \
    --unattended
else
  log "oh-my-zsh already installed"
fi

mkdir -p "$ZSH_CUSTOM_DIR/plugins"
clone_or_update "https://github.com/zsh-users/zsh-autosuggestions" \
  "$ZSH_CUSTOM_DIR/plugins/zsh-autosuggestions"
clone_or_update "https://github.com/zsh-users/zsh-syntax-highlighting" \
  "$ZSH_CUSTOM_DIR/plugins/zsh-syntax-highlighting"

mkdir -p "$(dirname "$TPM_DIR")"
clone_or_update "https://github.com/tmux-plugins/tpm" "$TPM_DIR"

if [[ -f "$HOME/.tmux.conf" ]]; then
  log "installing tmux plugins"
  "$TPM_DIR/bin/install_plugins"
else
  log "tmux config not installed yet; plugins will be installed during make setup"
fi
