#!/usr/bin/env bash
set -e

echo "==> FULL Git & GitHub reset (local machine)"
echo

# -------------------------------------------------
# 1. Stop using any SSH identities
# -------------------------------------------------
echo "==> Clearing ssh-agent identities..."
ssh-add -D >/dev/null 2>&1 || true

# -------------------------------------------------
# 2. Remove GitHub SSH keys
# -------------------------------------------------
echo "==> Removing GitHub SSH keys..."
rm -f ~/.ssh/id_ed25519 ~/.ssh/id_ed25519.pub
rm -f ~/.ssh/id_ed25519_* ~/.ssh/id_ed25519_*.pub

# -------------------------------------------------
# 3. Clean SSH config (GitHub hosts only)
# -------------------------------------------------
if [ -f ~/.ssh/config ]; then
  echo "==> Cleaning ~/.ssh/config..."
  sed -i '/# GitHub/,/^$/d' ~/.ssh/config
  sed -i '/Host github/d' ~/.ssh/config
fi

# -------------------------------------------------
# 4. Remove GitHub known_hosts entries
# -------------------------------------------------
echo "==> Removing GitHub known_hosts..."
ssh-keygen -R github.com >/dev/null 2>&1 || true
ssh-keygen -R github-personal >/dev/null 2>&1 || true
ssh-keygen -R github-work >/dev/null 2>&1 || true
ssh-keygen -R github-community >/dev/null 2>&1 || true

# -------------------------------------------------
# 5. Remove Git global identity
# -------------------------------------------------
echo "==> Removing Git global config..."
git config --global --unset user.name || true
git config --global --unset user.email || true
git config --global --unset core.editor || true

# -------------------------------------------------
# 6. Remove Git credentials
# -------------------------------------------------
git config --global --unset credential.helper || true
rm -f ~/.git-credentials

# -------------------------------------------------
# 7. Remove GitHub CLI auth (if installed)
# -------------------------------------------------
if command -v gh >/dev/null 2>&1; then
  echo "==> Logging out GitHub CLI..."
  gh auth logout -h github.com -y || true
fi

# -------------------------------------------------
# DONE
# -------------------------------------------------
echo
echo "✅ Git & GitHub completely removed from this system"
echo "System is ready for a fresh GitHub setup"

