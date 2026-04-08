SHELL   := /bin/bash
BINARY  := bin/git-wt
SCRIPTS := $(BINARY) install.sh

.PHONY: help lint test ci install clean

help: ## Show available targets
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*## "}; {printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

lint: ## Run ShellCheck on all shell scripts
	@command -v shellcheck >/dev/null 2>&1 || { echo "shellcheck not found — brew install shellcheck"; exit 1; }
	shellcheck $(SCRIPTS)
	@printf '\033[1;32m✔\033[0m  shellcheck passed\n'

test: ## Run smoke tests (same as CI)
	@chmod +x $(BINARY)
	@printf '\n\033[1;34m==>\033[0m Verify help output\n'
	$(BINARY) help
	@printf '\n\033[1;34m==>\033[0m Verify version output\n'
	$(BINARY) version | grep -q "git-wt"
	@printf '\033[1;32m✔\033[0m  version OK\n'
	@printf '\n\033[1;34m==>\033[0m Test add/list/path/remove/prune in a temp repo\n'
	@bash -c '\
		set -euo pipefail; \
		TMPDIR=$$(mktemp -d); \
		trap "rm -rf $$TMPDIR" EXIT; \
		cd "$$TMPDIR"; \
		git init -b main -q; \
		git config user.name "test"; \
		git config user.email "test@test"; \
		git commit --allow-empty -m "init" -q; \
		export PATH="$(CURDIR)/bin:$$PATH"; \
		git-wt add test-branch; \
		git-wt list | grep -q "test-branch"; \
		printf "\033[1;32m✔\033[0m  add + list OK\n"; \
		git-wt path test-branch >/dev/null; \
		printf "\033[1;32m✔\033[0m  path OK\n"; \
		git-wt remove test-branch; \
		printf "\033[1;32m✔\033[0m  remove OK\n"; \
		git-wt add test-branch-db; \
		git-wt remove test-branch-db --delete-branch; \
		git branch --list test-branch-db | grep -q "test-branch-db" && exit 1 || true; \
		printf "\033[1;32m✔\033[0m  remove --delete-branch OK\n"; \
		git-wt prune; \
		printf "\033[1;32m✔\033[0m  prune OK\n"; \
	'
	@printf '\n\033[1;32m✔  All tests passed\033[0m\n'

ci: lint test ## Run full CI pipeline (lint + test)

install: ## Install git-wt to /usr/local/bin
	bash install.sh

clean: ## Remove build artifacts
	rm -rf dist/
