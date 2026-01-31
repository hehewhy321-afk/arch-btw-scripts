# Arch Linux Mirror & System Optimization Script

Automatically optimizes your Arch Linux system by updating mirrors, parallel downloads, and build settings.

## ⚡ Features

- Automatically selects top 5 fastest nearby mirrors (India, Singapore, Japan, Nepal)
- Interactive prompt to set `ParallelDownloads` in `pacman.conf`
- Optimizes `makepkg` for multithreaded compression (faster builds)
- Creates systemd service + timer to refresh mirrors daily
- Displays exactly the 5 mirrors your system will actually use
- Fully works in bash (zsh currently not supported for interactive prompt)

## ⚠️ Warnings

- **Interactive prompt does NOT work in zsh** due to differences in `read` syntax. Run the script with bash only:
  ```bash
  sudo bash arch_mirror_optimize.sh
  ```
- Reflector may show occasional timeout warnings for some mirrors; this is normal. Only the fastest responsive mirrors are saved.

## 📋 Usage

1. **Download or clone this repository:**
   ```bash
   git clone <your-repo-url>
   cd <repo-folder>
   ```

2. **Make the script executable:**
   ```bash
   chmod +x arch_mirror_optimize.sh
   ```

3. **Run the script with bash:**
   ```bash
   sudo bash arch_mirror_optimize.sh
   ```

4. **Follow the prompt:**
   ```
   Enter desired number of parallel downloads (e.g., 10):
   ```

5. **Wait for completion** — the script will:
   - Install reflector if missing
   - Backup your current mirrorlist
   - Automatically pick top 5 fastest mirrors
   - Update `ParallelDownloads`
   - Optimize `makepkg` compression
   - Create systemd service + timer for daily mirror refresh
   - Update your package databases (`pacman -Syyu`)
   - Show top 5 mirrors your system will actually use

## 🛠 How it Works

- **Reflector** selects the fastest mirrors from nearby countries and saves them to `/etc/pacman.d/mirrorlist`.
- **ParallelDownloads** in `pacman.conf` allows multiple packages to download simultaneously. You choose the value interactively.
- **makepkg compression** is optimized with `-T0` to use all CPU cores.
- A **systemd timer** automatically refreshes mirrors daily, keeping your system fast and reliable.

## ✅ Example Output

```
==> Current ParallelDownloads in pacman.conf: 10

Enter desired number of parallel downloads (e.g., 10): 15

==> ParallelDownloads set to 15

==> Top 5 fastest mirrors currently active:
Server = https://mirror1.example.com/archlinux/$repo/os/$arch
Server = https://mirror2.example.com/archlinux/$repo/os/$arch
Server = https://mirror3.example.com/archlinux/$repo/os/$arch
Server = https://mirror4.example.com/archlinux/$repo/os/$arch
Server = https://mirror5.example.com/archlinux/$repo/os/$arch

✅ Arch optimization complete!
Mirrors refreshed, ParallelDownloads set to 15, multithreaded compression active, daily mirror refresh scheduled.
```

## 🔧 Notes

- You can modify the countries for mirror selection in the script:
  ```bash
  --country India,Singapore,Japan,Nepal
  ```
- You can increase or decrease the number of mirrors with:
  ```bash
  --fastest 5
  ```
- The script backs up your original mirrorlist as `/etc/pacman.d/mirrorlist.bak`

## 📝 License

[Add your license here]

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

## ⭐ Support

If this script helped optimize your Arch system, consider giving it a star!
