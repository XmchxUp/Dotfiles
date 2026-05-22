#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLATFORM=""

usage() {
  cat <<'EOF'
Usage: ./scripts/sync.sh [--platform macos|linux|windows]
EOF
}

log() {
  printf '[dotfiles] %s\n' "$*"
}

warn() {
  printf '[dotfiles] warning: %s\n' "$*" >&2
}

normalize_path() {
  local raw_path="$1"

  if command -v cygpath >/dev/null 2>&1; then
    cygpath -u "$raw_path"
  else
    printf '%s\n' "$raw_path"
  fi
}

detect_platform() {
  local kernel
  kernel="$(uname -s)"

  case "$kernel" in
    Darwin)
      printf 'macos\n'
      ;;
    Linux)
      if [[ "${OS:-}" == "Windows_NT" ]]; then
        printf 'windows\n'
      else
        printf 'linux\n'
      fi
      ;;
    MINGW*|MSYS*|CYGWIN*)
      printf 'windows\n'
      ;;
    *)
      warn "unsupported platform: $kernel"
      exit 1
      ;;
  esac
}

windows_home() {
  normalize_path "${USERPROFILE:-$HOME}"
}

vscode_user_dir() {
  case "$1" in
    macos)
      printf '%s\n' "$HOME/Library/Application Support/Code/User"
      ;;
    linux)
      printf '%s\n' "$HOME/.config/Code/User"
      ;;
    windows)
      if [[ -n "${APPDATA:-}" ]]; then
        printf '%s\n' "$(normalize_path "$APPDATA")/Code/User"
      else
        printf '%s\n' "$(windows_home)/AppData/Roaming/Code/User"
      fi
      ;;
  esac
}

alacritty_source() {
  case "$1" in
    macos|linux)
      printf '%s\n' "$HOME/.config/alacritty/alacritty.toml"
      ;;
    windows)
      if [[ -n "${APPDATA:-}" ]]; then
        printf '%s\n' "$(normalize_path "$APPDATA")/alacritty/alacritty.toml"
      else
        printf '%s\n' "$(windows_home)/AppData/Roaming/alacritty/alacritty.toml"
      fi
      ;;
  esac
}

ghostty_source() {
  printf '%s\n' "$HOME/.config/ghostty/config.ghostty"
}

copy_back() {
  local source="$1"
  local target="$2"

  if [[ ! -f "$source" ]]; then
    warn "source not found, skipping: $source"
    return
  fi

  cp "$source" "$target"
  log "synced $source -> $target"
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --platform)
        PLATFORM="${2:-}"
        shift 2
        ;;
      --help)
        usage
        exit 0
        ;;
      *)
        warn "unknown argument: $1"
        usage
        exit 1
        ;;
    esac
  done

  if [[ -z "$PLATFORM" ]]; then
    PLATFORM="$(detect_platform)"
  fi
}

main() {
  local vscode_dir

  parse_args "$@"

  vscode_dir="$(vscode_user_dir "$PLATFORM")"

  if [[ "$PLATFORM" == "windows" ]]; then
    copy_back "$(windows_home)/.gitconfig" "$REPO_ROOT/gitconfig"
    copy_back "$(alacritty_source "$PLATFORM")" "$REPO_ROOT/alacritty.windows.toml"
    copy_back "$vscode_dir/settings.json" "$REPO_ROOT/Vscode/settings.json"
    copy_back "$vscode_dir/keybindings.json" "$REPO_ROOT/Vscode/keybindings.json.windows"
    return
  fi

  copy_back "$HOME/.gitconfig" "$REPO_ROOT/gitconfig"
  copy_back "$HOME/.zshrc" "$REPO_ROOT/zshrc"
  copy_back "$HOME/.tmux.conf" "$REPO_ROOT/tmux.conf"
  copy_back "$(alacritty_source "$PLATFORM")" "$REPO_ROOT/alacritty.toml"
  copy_back "$(ghostty_source)" "$REPO_ROOT/ghostty/config.ghostty"
  copy_back "$vscode_dir/settings.json" "$REPO_ROOT/Vscode/settings.json"

  if [[ "$PLATFORM" == "macos" ]]; then
    copy_back "$vscode_dir/keybindings.json" "$REPO_ROOT/Vscode/keybindings.json.mac"
  else
    warn "linux keybindings target not configured; skipping"
  fi
}

main "$@"
