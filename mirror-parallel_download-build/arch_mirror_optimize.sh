#!/usr/bin/env bash
# Arch Linux Optimization Script
# Fully working in bash
# Features:
# - Automatic top 5 fastest nearby mirrors (IN, SG, JP, NP)
# - Interactive ParallelDownloads configuration
# - Multithreaded makepkg compression
# - Daily systemd mirror refresh
# - Displays exactly top 5 mirrors active

set -euo pipefail

# --- 1️⃣ Install reflector if missing ---
echo "==> Installing reflector..."
if ! command -v reflector >/dev/null 2>&1; then
    sudo pacman -Sy --noconfirm reflector >/dev/null
fi

# --- 2️⃣ Backup current mirrorlist ---
echo "==> Backing up current mirrorlist..."
sudo cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak

# --- 3️⃣ Auto-pick top 5 fastest nearby mirrors ---
echo "==> Selecting fastest nearby mirrors (IN, SG, JP, NP)..."
sudo reflector \
    --country India,Singapore,Japan,Nepal \
    --age 6 \
    --protocol https \
    --sort rate \
    --fastest 5 \
    --save /etc/pacman.d/mirrorlist

# --- 4️⃣ Interactive ParallelDownloads configuration ---
PACMAN_CONF="/etc/pacman.conf"
CURRENT=$(grep -E "^ParallelDownloads" "$PACMAN_CONF" | awk '{print $3}' || echo "5")
echo "==> Current ParallelDownloads in pacman.conf: $CURRENT"

read -r -p "Enter desired number of parallel downloads (e.g., 10): " USER_VALUE_INPUT

# Validate input is numeric and >0
if [[ "$USER_VALUE_INPUT" =~ ^[0-9]+$ ]] && [ "$USER_VALUE_INPUT" -gt 0 ]; then
    USER_VALUE=$USER_VALUE_INPUT
else
    echo "Invalid input. Using current value ($CURRENT)."
    USER_VALUE=$CURRENT
fi

# Update pacman.conf
if grep -q "^ParallelDownloads" "$PACMAN_CONF"; then
    sudo sed -i "s/^ParallelDownloads.*/ParallelDownloads = $USER_VALUE/" "$PACMAN_CONF"
else
    sudo sed -i "/#Misc options/a ParallelDownloads = $USER_VALUE" "$PACMAN_CONF"
fi
echo "==> ParallelDownloads set to $USER_VALUE"

# --- 5️⃣ Optimize makepkg compression ---
echo "==> Optimizing makepkg for multithreaded compression..."
MAKEPKG_CONF="/etc/makepkg.conf"
sudo sed -i 's/^#COMPRESSXZ=(xz -c -z -)/COMPRESSXZ=(xz -c -T0 -z -)/' "$MAKEPKG_CONF"

# --- 6️⃣ Create systemd service for daily mirror refresh ---
echo "==> Creating systemd service for daily mirror refresh..."
sudo tee /etc/systemd/system/reflector.service >/dev/null << 'EOF'
[Unit]
Description=Refresh Arch Linux mirrorlist using Reflector

[Service]
Type=oneshot
ExecStart=/usr/bin/reflector --country India,Singapore,Japan,Nepal --age 12 --protocol https --sort rate --fastest 5 --save /etc/pacman.d/mirrorlist
EOF

# --- 7️⃣ Create systemd timer for daily execution ---
echo "==> Creating systemd timer..."
sudo tee /etc/systemd/system/reflector.timer >/dev/null << 'EOF'
[Unit]
Description=Daily Mirrorlist Refresh

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
EOF

# --- 8️⃣ Enable and start the timer ---
echo "==> Enabling and starting reflector timer..."
sudo systemctl daemon-reload
sudo systemctl enable --now reflector.timer

# --- 9️⃣ Update package databases ---
echo "==> Updating package databases..."
sudo pacman -Syyu --noconfirm 2>/dev/null

# --- 🔟 Show exactly top 5 fastest mirrors active ---
echo "==> Top 5 fastest mirrors currently active:"
sudo grep "^Server" /etc/pacman.d/mirrorlist | head -n 5

echo "✅ Arch optimization complete!"
echo "Mirrors refreshed, ParallelDownloads set to $USER_VALUE, multithreaded compression active, daily mirror refresh scheduled."
