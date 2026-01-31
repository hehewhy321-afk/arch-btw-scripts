#!/usr/bin/env bash
set -euo pipefail

echo "==> Advanced GitHub multi-account SSH setup (Arch Linux)"
echo

# -------------------------------------------------
# 0. Requirements
# -------------------------------------------------
echo "==> Installing required packages..."
sudo pacman -Sy --needed --noconfirm git openssh

# -------------------------------------------------
# 1. systemd ssh-agent (single source of truth)
# -------------------------------------------------
echo "==> Enabling systemd ssh-agent..."
systemctl --user enable --now ssh-agent.service
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

SOCK_EXPORT='export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"'
for rc in "$HOME/.bashrc" "$HOME/.zshrc"; do
  [ -f "$rc" ] && grep -q ssh-agent.socket "$rc" || echo "$SOCK_EXPORT" >> "$rc"
done

# -------------------------------------------------
# 2. Prepare SSH directory
# -------------------------------------------------
mkdir -p ~/.ssh
chmod 700 ~/.ssh
touch ~/.ssh/config
chmod 600 ~/.ssh/config

# -------------------------------------------------
# 3. Fixed-role account setup
# -------------------------------------------------
setup_account() {
  local ROLE="$1"          # personal | work | community
  local LABEL="$2"         # PERSONAL | WORK | COMMUNITY

  echo
  read -rp "Enable $LABEL GitHub account? (y/N): " CONFIRM
  
  # FIX: Check if user declined, then return early without triggering set -e
  if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
    echo "Skipping $LABEL account setup."
    return 0
  fi

  KEY_PATH="$HOME/.ssh/id_ed25519_github_${ROLE}"
  HOST_ALIAS="github-${ROLE}"

  if [ ! -f "$KEY_PATH" ]; then
    echo "==> Generating SSH key for $LABEL..."
    ssh-keygen -t ed25519 -f "$KEY_PATH" -C "github-${ROLE}" -N ""
  else
    echo "==> SSH key already exists for $LABEL"
  fi

  ssh-add -q "$KEY_PATH"

  if ! grep -q "Host $HOST_ALIAS" ~/.ssh/config; then
    cat >> ~/.ssh/config <<EOF

# GitHub ($LABEL)
Host $HOST_ALIAS
    HostName github.com
    User git
    IdentityFile $KEY_PATH
    IdentitiesOnly yes
EOF
  fi

  echo
  echo "==> ADD THIS SSH KEY TO GITHUB ($LABEL ACCOUNT)"
  echo "------------------------------------------------"
  cat "${KEY_PATH}.pub"
  echo "------------------------------------------------"
  echo "GitHub → Settings → SSH and GPG keys → New SSH key"
  echo "Press Enter AFTER adding the key"
  read
}

# -------------------------------------------------
# 4. Role-based setup (hardcoded, predictable)
# -------------------------------------------------
echo
echo "You can configure the following GitHub accounts:"
echo "  1) personal"
echo "  2) work"
echo "  3) community"
echo

setup_account "personal" "PERSONAL"
setup_account "work" "WORK"
setup_account "community" "COMMUNITY"

# -------------------------------------------------
# 5. Final verification instructions
# -------------------------------------------------
echo
echo "==> Setup complete!"
echo
echo "VERIFY (run only for enabled accounts):"
echo "  ssh -T git@github-personal"
echo "  ssh -T git@github-work"
echo "  ssh -T git@github-community"
echo
echo "CLONE FORMAT:"
echo "  git clone git@github-personal:<username>/<repo>.git"
echo "  git clone git@github-work:<org>/<repo>.git"
echo "  git clone git@github-community:<org>/<repo>.git"
