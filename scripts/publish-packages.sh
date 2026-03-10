#!/usr/bin/env bash
set -euo pipefail

OWNER="silasvasconcelos"
REPO="simple-git-worktreee"
HOMEBREW_TAP_REPO="$OWNER/homebrew-tap"
SCOOP_BUCKET_REPO="$OWNER/scoop-bucket"

die()     { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }
info()    { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
success() { printf '\033[1;32m✔\033[0m  %s\n' "$*"; }

command -v gh >/dev/null 2>&1  || die "gh (GitHub CLI) is required"
command -v curl >/dev/null 2>&1 || die "curl is required"

VERSION="${1:-}"
[ -z "$VERSION" ] && die "usage: $0 <version>  (e.g. 1.0.0)"

TAG="v$VERSION"

info "verifying release $TAG exists on ${OWNER}/${REPO}…"
gh release view "$TAG" --repo "$OWNER/$REPO" >/dev/null 2>&1 \
  || die "release $TAG not found — create the GitHub release first"

# ── Homebrew tap ──────────────────────────────────────────────────────

info "computing SHA256 for source tarball…"
TARBALL_URL="https://github.com/$OWNER/$REPO/archive/refs/tags/$TAG.tar.gz"
TARBALL_SHA=$(curl -sL "$TARBALL_URL" | shasum -a 256 | awk '{print $1}')
info "sha256: $TARBALL_SHA"

FORMULA=$(cat <<RUBY
class SimpleGitWorktree < Formula
  desc "Simple git worktree manager"
  homepage "https://github.com/$OWNER/$REPO"
  url "$TARBALL_URL"
  sha256 "$TARBALL_SHA"
  license "MIT"

  depends_on "git"

  def install
    bin.install "bin/git-wt"
  end

  test do
    assert_match "git-wt", shell_output("#{bin}/git-wt version")
  end
end
RUBY
)

info "pushing Formula/simple-git-worktree.rb to ${HOMEBREW_TAP_REPO}…"

if gh api "repos/$HOMEBREW_TAP_REPO/contents/Formula/simple-git-worktree.rb" >/dev/null 2>&1; then
  FORMULA_SHA=$(gh api "repos/$HOMEBREW_TAP_REPO/contents/Formula/simple-git-worktree.rb" --jq '.sha')
  gh api --method PUT "repos/$HOMEBREW_TAP_REPO/contents/Formula/simple-git-worktree.rb" \
    -f message="simple-git-worktree $TAG" \
    -f content="$(printf '%s' "$FORMULA" | base64)" \
    -f sha="$FORMULA_SHA" \
    --silent
else
  gh api --method PUT "repos/$HOMEBREW_TAP_REPO/contents/Formula/simple-git-worktree.rb" \
    -f message="simple-git-worktree $TAG" \
    -f content="$(printf '%s' "$FORMULA" | base64)" \
    --silent
fi

success "homebrew-tap updated"

# ── Scoop bucket ──────────────────────────────────────────────────────

info "computing SHA256 for release zip…"
ZIP_URL="https://github.com/$OWNER/$REPO/releases/download/$TAG/simple-git-worktree-$TAG.zip"
ZIP_SHA=$(curl -sL "$ZIP_URL" | shasum -a 256 | awk '{print $1}')
info "sha256: $ZIP_SHA"

MANIFEST=$(cat <<JSON
{
  "version": "$VERSION",
  "description": "Simple git worktree manager",
  "homepage": "https://github.com/$OWNER/$REPO",
  "license": "MIT",
  "url": "$ZIP_URL",
  "hash": "$ZIP_SHA",
  "bin": "bin/git-wt",
  "post_install": "git config --global alias.wt '!git-wt'"
}
JSON
)

info "pushing simple-git-worktree.json to ${SCOOP_BUCKET_REPO}…"

if gh api "repos/$SCOOP_BUCKET_REPO/contents/simple-git-worktree.json" >/dev/null 2>&1; then
  MANIFEST_SHA=$(gh api "repos/$SCOOP_BUCKET_REPO/contents/simple-git-worktree.json" --jq '.sha')
  gh api --method PUT "repos/$SCOOP_BUCKET_REPO/contents/simple-git-worktree.json" \
    -f message="simple-git-worktree $TAG" \
    -f content="$(printf '%s' "$MANIFEST" | base64)" \
    -f sha="$MANIFEST_SHA" \
    --silent
else
  gh api --method PUT "repos/$SCOOP_BUCKET_REPO/contents/simple-git-worktree.json" \
    -f message="simple-git-worktree $TAG" \
    -f content="$(printf '%s' "$MANIFEST" | base64)" \
    --silent
fi

success "scoop-bucket updated"

echo ""
success "all packages published for $TAG"
