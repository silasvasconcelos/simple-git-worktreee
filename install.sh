#!/usr/bin/env bash
set -euo pipefail

REPO="silasvasconcelos/simple-git-worktreee"
BINARY="git-wt"
INSTALL_DIR="/usr/local/bin"

info()    { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
success() { printf '\033[1;32m✔\033[0m  %s\n' "$*"; }
die()     { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

command -v git >/dev/null 2>&1 || die "git is required but not installed"
command -v curl >/dev/null 2>&1 || die "curl is required but not installed"

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

info "downloading $BINARY…"
curl -fsSL "https://raw.githubusercontent.com/$REPO/main/bin/$BINARY" -o "$TMPDIR/$BINARY"

chmod +x "$TMPDIR/$BINARY"

info "installing to $INSTALL_DIR/$BINARY…"
if [ -w "$INSTALL_DIR" ]; then
  mv "$TMPDIR/$BINARY" "$INSTALL_DIR/$BINARY"
else
  sudo mv "$TMPDIR/$BINARY" "$INSTALL_DIR/$BINARY"
fi

info "configuring git alias…"
git config --global alias.wt '!git-wt'

success "installed! run 'git wt help' to get started"
