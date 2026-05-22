#!/usr/bin/env bash

set -euo pipefail

REPO_ROOT="$(cd -- "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "[dotfiles] warning: this setup script only supports macOS" >&2
  exit 1
fi

"$REPO_ROOT/scripts/install-tools-macos.sh"
"$REPO_ROOT/scripts/install.sh" --platform macos

if [[ -x "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]]; then
  "$HOME/.tmux/plugins/tpm/bin/install_plugins"
fi
