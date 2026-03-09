# Packaging

## .deb (Debian / Ubuntu)

```bash
VERSION="1.0.0"

mkdir -p "simple-git-worktree_${VERSION}/usr/local/bin"
cp bin/git-wt "simple-git-worktree_${VERSION}/usr/local/bin/"

mkdir -p "simple-git-worktree_${VERSION}/DEBIAN"
cat > "simple-git-worktree_${VERSION}/DEBIAN/control" <<EOF
Package: simple-git-worktree
Version: ${VERSION}
Section: vcs
Priority: optional
Architecture: all
Depends: git
Maintainer: Silas Vasconcelos
Description: Simple git worktree manager
EOF

dpkg-deb --build "simple-git-worktree_${VERSION}"
```

Install the resulting package:

```bash
sudo dpkg -i "simple-git-worktree_${VERSION}.deb"
```

## .rpm (Fedora / RHEL / openSUSE)

Create the spec file `simple-git-worktree.spec`:

```spec
Name:           simple-git-worktree
Version:        1.0.0
Release:        1%{?dist}
Summary:        Simple git worktree manager
License:        MIT
URL:            https://github.com/silasvasconcelos/simple-git-worktreee
Source0:        %{name}-%{version}.tar.gz
BuildArch:      noarch
Requires:       git

%description
A dead-simple CLI that wraps git worktree so you can manage worktrees
without remembering paths or flags.

%install
mkdir -p %{buildroot}/usr/local/bin
cp -a bin/git-wt %{buildroot}/usr/local/bin/git-wt
chmod 755 %{buildroot}/usr/local/bin/git-wt

%files
/usr/local/bin/git-wt
```

Build the package:

```bash
rpmbuild -bb simple-git-worktree.spec
```

## Homebrew (macOS / Linux)

The formula lives at `Formula/simple-git-worktree.rb`. To publish a new version:

1. Tag a release (`v<VERSION>`) — the release workflow computes the SHA256 automatically.
2. The `homebrew` job in `.github/workflows/release.yml` pushes the updated formula to the [homebrew-tap](https://github.com/silasvasconcelos/homebrew-tap) repo.

To test the formula locally:

```bash
brew install --build-from-source ./Formula/simple-git-worktree.rb
brew test simple-git-worktree
```

## Scoop (Windows)

The manifest lives at `scoop-manifest.json`. To publish a new version:

1. Tag a release (`v<VERSION>`) — the release workflow builds the `.zip` and computes the SHA256.
2. The `scoop` job in `.github/workflows/release.yml` pushes the updated manifest to the [scoop-bucket](https://github.com/silasvasconcelos/scoop-bucket) repo.

To test the manifest locally:

```powershell
scoop install .\scoop-manifest.json
```

## Tarball / Zip (generic)

Create distributable archives manually:

```bash
VERSION="1.0.0"

# tarball
tar czf "simple-git-worktree-v${VERSION}.tar.gz" \
  bin/git-wt install.sh install.ps1 README.md LICENSE

# zip
zip "simple-git-worktree-v${VERSION}.zip" \
  bin/git-wt install.sh install.ps1 README.md LICENSE
```

These are the same artifacts the release workflow produces and attaches to each GitHub Release.
