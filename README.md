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
| `git wt add <branch> [base] [--go]` | Create a worktree from current branch. `--go` outputs path for `cd` |
| `git wt list` | List all worktrees |
| `git wt remove <branch>` | Remove a worktree |
| `git wt prune` | Clean up stale worktree references |
| `git wt path <branch>` | Print the absolute path of a worktree |
| `git wt root` | Print the main repository root path |
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
# ==> creating worktree for 'feature-login' based on 'develop'…
# ✔ worktree created at .worktrees/feature-login

cd .worktrees/feature-login
# You now have a full checkout — run tests, edit code, etc.
```

### Create and jump into the worktree with `--go`

```bash
cd "$(git wt add feature-login --go)"
# ==> creating worktree for 'feature-login' based on 'develop'…
# ✔ worktree created at .worktrees/feature-login
# You're now inside .worktrees/feature-login
```

> **Tip:** Add a shell function to your `.bashrc` / `.zshrc` for even less typing:
>
> ```bash
> gwt() { cd "$(git wt add "$@" --go)"; }
> ```
>
> Then just: `gwt feature-login`

### Branch from a specific base instead of the current branch

```bash
git wt add feature-payment main
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

### Go back to the project root

```bash
# From any worktree, return to the main project directory
cd "$(git wt root)"
```

This works from anywhere — inside a worktree, a subdirectory, or the main repo itself. It always resolves to the original project root.

### Prune orphaned references

```bash
git wt prune
```

---

## Hooks

You can run custom commands before and after worktree operations by creating a `.git-wtrc` file in your repository root.

### Configuration

Create a `.git-wtrc` file with `key = command` pairs:

```ini
# .git-wtrc — hook configuration for git-wt

# Runs before creating a worktree
pre-add = echo "Setting up $GIT_WT_BRANCH…"

# Runs after creating a worktree (e.g. install dependencies)
post-add = cd $GIT_WT_PATH && npm install

# Runs before removing a worktree
pre-remove = echo "Cleaning up $GIT_WT_BRANCH…"

# Runs after removing a worktree
post-remove = echo "Done removing $GIT_WT_BRANCH"
```

### Available hooks

| Hook | Trigger |
|---|---|
| `pre-add` | Before worktree creation |
| `post-add` | After worktree creation |
| `pre-remove` | Before worktree removal |
| `post-remove` | After worktree removal |

### Environment variables

Each hook receives these environment variables:

| Variable | Description | Available in |
|---|---|---|
| `GIT_WT_BRANCH` | Branch name | All hooks |
| `GIT_WT_PATH` | Absolute path of the worktree | All hooks |
| `GIT_WT_ROOT` | Repository root path | All hooks |
| `GIT_WT_BASE` | Base branch name | `pre-add`, `post-add` |

### Hook examples

**Install dependencies after creating a worktree:**

```ini
post-add = cd $GIT_WT_PATH && npm install
```

**Run a Python setup script:**

```ini
post-add = python3 ./scripts/setup-worktree.py
```

**Use a Ruby script for cleanup:**

```ini
post-remove = ruby ./scripts/cleanup.rb
```

**Backup before removal:**

```ini
pre-remove = tar czf "/tmp/${GIT_WT_BRANCH}-backup.tar.gz" "$GIT_WT_PATH"
```

**Chain multiple commands:**

```ini
post-add = cd $GIT_WT_PATH && cp ../.env.example .env && npm install && npm run db:migrate
```

> **Note:** A failing `pre-*` hook aborts the operation. A failing `post-*` hook logs a warning but does not roll back.

---

## Real-world workflow

```bash
# 1. Start a hotfix — jump straight into it with --go
cd "$(git wt add hotfix-auth --go)"

# 2. Fix the bug in the hotfix worktree
vim src/auth.js
git add -A && git commit -m "fix: auth token expiry"
git push origin hotfix-auth

# 3. Go back to main project root — your feature branch is untouched
cd "$(git wt root)"

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
