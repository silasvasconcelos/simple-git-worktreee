# simple-git-worktree

A dead-simple CLI that wraps `git worktree` so you can manage worktrees without remembering paths or flags.

```
git wt add feature-login        # create a worktree
git wt list                     # see all worktrees
git wt remove feature-login     # clean up
```

All worktrees live inside a `.worktrees/` folder in your repo — automatically created and git-ignored.

```
my-project/
├── src/
├── .worktrees/
│   ├── feature-login/
│   └── feature-payment/
└── ...
```

---

## Why?

`git worktree` is powerful but verbose. You have to specify full paths, remember to create directories, and manage cleanup yourself. **simple-git-worktree** reduces all of that to one short command: `git wt`.

---

## Commands

| Command | Description |
|---|---|
| `git wt add <branch> [base]` | Create a worktree. Base defaults to `main` |
| `git wt list` | List all worktrees |
| `git wt remove <branch>` | Remove a worktree |
| `git wt prune` | Clean up stale worktree references |
| `git wt path <branch>` | Print the absolute path of a worktree |
| `git wt help` | Show help |
| `git wt version` | Show version |

---

## Installation

### Quick install (Linux / macOS)

```bash
curl -sL https://raw.githubusercontent.com/silasvasconcelos/simple-git-worktreee/main/install.sh | bash
```

### Quick install (Windows PowerShell)

```powershell
irm https://raw.githubusercontent.com/silasvasconcelos/simple-git-worktreee/main/install.ps1 | iex
```

### Homebrew (macOS / Linux)

```bash
brew tap silasvasconcelos/tap
brew install simple-git-worktree
```

### Scoop (Windows)

```powershell
scoop bucket add silasvasconcelos https://github.com/silasvasconcelos/scoop-bucket
scoop install simple-git-worktree
```

### Manual install (Linux / macOS)

```bash
git clone https://github.com/silasvasconcelos/simple-git-worktreee.git
cd simple-git-worktreee
chmod +x bin/git-wt
sudo cp bin/git-wt /usr/local/bin/
git config --global alias.wt '!git-wt'
```

### Manual install (Windows)

```powershell
git clone https://github.com/silasvasconcelos/simple-git-worktreee.git
Copy-Item simple-git-worktreee\bin\git-wt "$env:LOCALAPPDATA\Programs\git-wt\git-wt"
git config --global alias.wt "!git-wt"
```

> Make sure `$env:LOCALAPPDATA\Programs\git-wt` is in your `PATH`.

---

## Usage examples

### Start working on a feature

```bash
cd my-project
git wt add feature-login
# ==> created .worktrees/
# ==> fetching from origin…
# ==> creating worktree for 'feature-login' based on 'main'…
# ✔ worktree created at .worktrees/feature-login

cd .worktrees/feature-login
# You now have a full checkout — run tests, edit code, etc.
```

### Branch from develop instead of main

```bash
git wt add feature-payment develop
```

### See all active worktrees

```bash
git wt list
# /Users/you/my-project              abc1234 [main]
# /Users/you/my-project/.worktrees/feature-login  def5678 [feature-login]
```

### Get the path to open in another terminal

```bash
code "$(git wt path feature-login)"
```

### Clean up when done

```bash
git wt remove feature-login
# ==> removing worktree 'feature-login'…
# ✔ worktree 'feature-login' removed
```

### Prune orphaned references

```bash
git wt prune
```

---

## Real-world workflow

```bash
# 1. Start a hotfix while your feature branch is still in progress
git wt add hotfix-auth

# 2. Fix the bug in the hotfix worktree
cd .worktrees/hotfix-auth
vim src/auth.js
git add -A && git commit -m "fix: auth token expiry"
git push origin hotfix-auth

# 3. Go back to main worktree — your feature branch is untouched
cd ../..

# 4. Clean up after the hotfix is merged
git wt remove hotfix-auth
git wt prune
```

---

## Packaging

### Creating a .deb package (Debian / Ubuntu)

```bash
mkdir -p simple-git-worktree_1.0.0/usr/local/bin
cp bin/git-wt simple-git-worktree_1.0.0/usr/local/bin/

mkdir -p simple-git-worktree_1.0.0/DEBIAN
cat > simple-git-worktree_1.0.0/DEBIAN/control <<EOF
Package: simple-git-worktree
Version: 1.0.0
Section: vcs
Priority: optional
Architecture: all
Depends: git
Maintainer: Silas Vasconcelos
Description: Simple git worktree manager
EOF

dpkg-deb --build simple-git-worktree_1.0.0
```

---

## Uninstall

```bash
# Linux / macOS
sudo rm /usr/local/bin/git-wt
git config --global --unset alias.wt

# Windows (PowerShell)
Remove-Item "$env:LOCALAPPDATA\Programs\git-wt" -Recurse -Force
git config --global --unset alias.wt
```

---

## Contributing

1. Fork the repo
2. Create a feature branch: `git checkout -b my-feature`
3. Commit your changes: `git commit -m "feat: add my feature"`
4. Push: `git push origin my-feature`
5. Open a Pull Request

Please follow [Conventional Commits](https://www.conventionalcommits.org/) for commit messages.

---

## License

[MIT](LICENSE)
