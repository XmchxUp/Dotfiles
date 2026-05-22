#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODE="symlink"
DRY_RUN=0
WITH_TOOLS=0
PLATFORM=""
BACKUP_ROOT="${DOTFILES_BACKUP_DIR:-$HOME/.dotfiles-backup}"
BACKUP_DIR=""

usage() {
  cat <<'EOF'
Usage: ./scripts/install.sh [options]

Options:
  --mode symlink|copy   Install via symlink or copy. Default: symlink
  --platform VALUE      Force platform: macos, linux, windows
  --with-tools          Install Brewfile tools on macOS after config install
  --dry-run             Print actions without changing files
  --help                Show this help
EOF
}

log() {
  printf '[dotfiles] %s\n' "$*"
}

warn() {
  printf '[dotfiles] warning: %s\n' "$*" >&2
}

run_cmd() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf '[dry-run]'
    printf ' %q' "$@"
    printf '\n'
    return 0
  fi

  "$@"
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

alacritty_target() {
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

ghostty_target() {
  printf '%s\n' "$HOME/.config/ghostty/config.ghostty"
}

ensure_backup_dir() {
  if [[ -n "$BACKUP_DIR" ]]; then
    return
  fi

  BACKUP_DIR="$BACKUP_ROOT/$(date +%Y%m%d-%H%M%S)"
  run_cmd mkdir -p "$BACKUP_DIR"
}

backup_target() {
  local target="$1"
  local backup_path

  ensure_backup_dir
  backup_path="$BACKUP_DIR/${target#/}"

  run_cmd mkdir -p "$(dirname "$backup_path")"
  run_cmd mv "$target" "$backup_path"
  log "backed up $target -> $backup_path"
}

ensure_parent_dir() {
  run_cmd mkdir -p "$(dirname "$1")"
}

same_symlink() {
  local source="$1"
  local target="$2"

  [[ -L "$target" ]] && [[ "$(readlink "$target")" == "$source" ]]
}

same_file() {
  local source="$1"
  local target="$2"

  [[ -f "$target" ]] && cmp -s "$source" "$target"
}

install_file() {
  local source="$1"
  local target="$2"

  if [[ ! -e "$source" ]]; then
    warn "missing source file: $source"
    return
  fi

  ensure_parent_dir "$target"

  if [[ "$MODE" == "symlink" ]] && same_symlink "$source" "$target"; then
    log "already linked: $target"
    return
  fi

  if [[ "$MODE" == "copy" ]] && same_file "$source" "$target"; then
    log "already up to date: $target"
    return
  fi

  if [[ -e "$target" || -L "$target" ]]; then
    backup_target "$target"
  fi

  if [[ "$MODE" == "symlink" ]]; then
    run_cmd ln -s "$source" "$target"
  else
    run_cmd cp "$source" "$target"
  fi

  log "installed $target"
}

install_gitconfig() {
  local home_dir

  if [[ "$PLATFORM" == "windows" ]]; then
    home_dir="$(windows_home)"
  else
    home_dir="$HOME"
  fi

  install_file "$REPO_ROOT/gitconfig" "$home_dir/.gitconfig"
}

install_zshrc() {
  install_file "$REPO_ROOT/zshrc" "$HOME/.zshrc"
}

install_tmux() {
  install_file "$REPO_ROOT/tmux.conf" "$HOME/.tmux.conf"
}

install_alacritty() {
  local source="$REPO_ROOT/alacritty.toml"

  if [[ "$PLATFORM" == "windows" ]]; then
    source="$REPO_ROOT/alacritty.windows.toml"
  fi

  install_file "$source" "$(alacritty_target "$PLATFORM")"
}

install_ghostty() {
  if [[ "$PLATFORM" == "windows" ]]; then
    warn "ghostty config is not configured for windows; skipping"
    return
  fi

  install_file "$REPO_ROOT/ghostty/config.ghostty" "$(ghostty_target)"
}

install_vscode() {
  local user_dir
  local keybindings_source=""

  user_dir="$(vscode_user_dir "$PLATFORM")"

  install_file "$REPO_ROOT/Vscode/settings.json" "$user_dir/settings.json"

  case "$PLATFORM" in
    macos)
      keybindings_source="$REPO_ROOT/Vscode/keybindings.json.mac"
      ;;
    windows)
      keybindings_source="$REPO_ROOT/Vscode/keybindings.json.windows"
      ;;
    linux)
      warn "linux keybindings file not configured; skipping keybindings.json"
      ;;
  esac

  if [[ -n "$keybindings_source" ]]; then
    install_file "$keybindings_source" "$user_dir/keybindings.json"
  fi
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --mode)
        MODE="${2:-}"
        shift 2
        ;;
      --platform)
        PLATFORM="${2:-}"
        shift 2
        ;;
      --with-tools)
        WITH_TOOLS=1
        shift
        ;;
      --dry-run)
        DRY_RUN=1
        shift
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

  if [[ "$MODE" != "symlink" && "$MODE" != "copy" ]]; then
    warn "invalid mode: $MODE"
    exit 1
  fi

  if [[ -z "$PLATFORM" ]]; then
    PLATFORM="$(detect_platform)"
  fi

  case "$PLATFORM" in
    macos|linux|windows)
      ;;
    *)
      warn "invalid platform: $PLATFORM"
      exit 1
      ;;
  esac
}

main() {
  parse_args "$@"

  log "repo: $REPO_ROOT"
  log "platform: $PLATFORM"
  log "mode: $MODE"

  install_gitconfig
  install_zshrc
  install_tmux
  install_alacritty
  install_ghostty
  install_vscode

  if [[ "$WITH_TOOLS" -eq 1 ]]; then
    if [[ "$PLATFORM" != "macos" ]]; then
      warn "--with-tools is currently only supported on macOS"
    else
      "$REPO_ROOT/scripts/install-tools-macos.sh"
    fi
  fi

  if [[ -n "$BACKUP_DIR" ]]; then
    log "backup directory: $BACKUP_DIR"
  fi
}

main "$@"
