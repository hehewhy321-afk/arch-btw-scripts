# 🔱 GitHub Multi-Account SSH Setup for Arch Linux

> *"I use Arch btw, and I also use multiple GitHub accounts btw"*

A bulletproof script to manage multiple GitHub accounts on Arch Linux without losing your sanity. Works with systemd ssh-agent because we're not savages using `eval $(ssh-agent)` in our shell configs.

---

## 🎯 What This Does

- ✅ Sets up separate SSH keys for personal, work, and community GitHub accounts
- ✅ Uses systemd ssh-agent (the Arch way™)
- ✅ Creates clean SSH config with predictable aliases
- ✅ Lets you skip accounts you don't need
- ✅ Auto-configures Git identity based on project directory
- ✅ Doesn't explode when you press "N"

---

## 📦 What's Included

```
.
├── github-multi-setup.sh     # Main setup script
├── git-github-reset.sh       # Nuclear option (reset everything)
└── README.md                 # You are here
```

---

## 🚀 Initial Setup

### Step 1: Run the Script

```bash
chmod +x github-multi-setup.sh
./github-multi-setup.sh
```

### Step 2: Answer the Prompts

The script will ask about each account:

```
Enable PERSONAL GitHub account? (y/N): y
Enable WORK GitHub account? (y/N): N
Enable COMMUNITY GitHub account? (y/N): y
```

Press `y` for accounts you want, `N` to skip. **It won't rage-quit if you skip one.**

### Step 3: Add SSH Keys to GitHub

For each account you enabled, the script will print your **public key**. 

1. Copy the entire key (starts with `ssh-ed25519`)
2. Go to GitHub → Settings → SSH and GPG keys → New SSH key
3. Paste and save
4. Press Enter in the terminal to continue

**Do this for EACH account you enabled.**

### Step 4: Verify It Works

Test each enabled account:

```bash
ssh -T git@github-personal
ssh -T git@github-work
ssh -T git@github-community
```

Expected output:
```
Hi YourUsername! You've successfully authenticated, but GitHub does not provide shell access.
```

If you see that, you're golden. If not, see [Troubleshooting](#-troubleshooting).

---

## 📁 Recommended Folder Structure

Since you're using multiple accounts, organize your projects by account type:

```
~/projects/
├── personal/        # Personal GitHub projects
│   ├── my-blog/
│   └── side-project/
├── community/       # Community/Open-source projects (PRIMARY)
│   ├── start-agency/
│   └── awesome-tool/
└── work/            # Work-related projects
    ├── company-app/
    └── internal-tool/
```

**Why?** Because you can auto-configure Git identity per directory. Read on.

---

## 🎨 Configure Git Identity (IMPORTANT!)

SSH handles **authentication** (who you are), but Git needs to know your **name and email** for commits.

### Option 1: Per-Repository (Manual)

After cloning any repo:

```bash
cd ~/projects/community/start-agency
git config user.name "Your Name"
git config user.email "community@example.com"
```

**Downside:** You have to do this for EVERY repo. Annoying.

### Option 2: Auto-Magic Per-Directory (RECOMMENDED)

Edit `~/.gitconfig`:

```bash
nano ~/.gitconfig
```

Add this:

```ini
# Default identity (use your PRIMARY account)
[user]
    name = Your Name
    email = your-community-email@example.com

# Override for personal projects only
[includeIf "gitdir:~/projects/personal/"]
    path = ~/.gitconfig-personal

# Override for work projects only
[includeIf "gitdir:~/projects/work/"]
    path = ~/.gitconfig-work
```

Create override files:

**`~/.gitconfig-personal`:**
```ini
[user]
    name = Your Name
    email = your-personal-email@example.com
```

**`~/.gitconfig-work`:**
```ini
[user]
    name = Your Work Name
    email = your-work-email@company.com
```

Now Git automatically uses the right identity based on which folder you're in. *Chef's kiss.*

### Verify It Works

```bash
cd ~/projects/community/start-agency
git config user.email
# Output: your-community-email@example.com

cd ~/projects/personal/my-blog
git config user.email
# Output: your-personal-email@example.com
```

---

## 🔧 How to Clone Repos

**⚠️ CRITICAL: Use the correct SSH alias!**

### Clone Format

```bash
git clone git@github-ALIAS:USERNAME/REPO.git
```

### Examples

```bash
# Personal account
git clone git@github-personal:yourusername/my-blog.git ~/projects/personal/my-blog

# Community account
git clone git@github-community:hehewhy321-afk/start-agency.git ~/projects/community/start-agency

# Work account
git clone git@github-work:company/internal-tool.git ~/projects/work/internal-tool
```

### ❌ Common Mistakes

```bash
# WRONG - will use wrong SSH key
git clone git@github.com:yourusername/repo.git

# WRONG - won't work at all
git clone git@yourusername:repo.git

# RIGHT
git clone git@github-personal:yourusername/repo.git
```

---

## 🧪 Daily Workflow Example

```bash
# Clone a community project
cd ~/projects/community
git clone git@github-community:hehewhy321-afk/start-agency.git
cd start-agency

# Verify Git identity (should auto-detect from directory)
git config user.email
# Output: your-community-email@example.com ✅

# Make changes
echo "# TODO" >> TODO.md
git add TODO.md
git commit -m "Add TODO file"
git push

# No password prompts, no drama, just works™
```

---

## ⚠️ Warnings & Gotchas

### 🔴 Don't Mix Accounts in the Same Repo

If you clone with the wrong alias, you'll authenticate with the wrong account. **Always double-check the alias.**

### 🔴 SSH Agent Must Be Running

The script enables `ssh-agent.service` via systemd. If you reboot and it's not running:

```bash
systemctl --user enable --now ssh-agent.service
```

### 🔴 GitHub Email Must Match

The email in your Git config **must be associated** with your GitHub account, or commits won't show your profile picture.

Check: GitHub → Settings → Emails

### 🔴 IdentitiesOnly is Critical

The SSH config includes `IdentitiesOnly yes` to prevent SSH from trying all your keys. **Don't remove this line** unless you enjoy debugging "too many authentication failures" errors.

---

## 🆘 Troubleshooting

### "Permission denied (publickey)"

**Cause:** SSH key not added to GitHub or wrong alias used.

**Fix:**
1. Verify SSH connection: `ssh -T git@github-community`
2. If it fails, re-add the public key to GitHub
3. Check you're using the right alias in the clone URL

### "Hi WRONG_USERNAME! You've successfully authenticated..."

**Cause:** You used the wrong SSH alias.

**Fix:** 
1. Check your remote: `git remote -v`
2. Update it: `git remote set-url origin git@github-CORRECT:user/repo.git`

### "Could not open a connection to your authentication agent"

**Cause:** ssh-agent isn't running.

**Fix:**
```bash
systemctl --user start ssh-agent.service
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
```

### "Everything is broken and I hate computers"

**Cause:** Life is pain and Arch Linux is a harsh mistress.

**Fix:** Use the nuclear option ⬇️

---

## ☢️ Nuclear Option: Reset Everything

Made a mess? Want to start fresh? Run the reset script:

```bash
./git-github-reset.sh
```

**⚠️ WARNING:** This will:
- Delete ALL SSH keys for GitHub (`~/.ssh/id_ed25519_github_*`)
- Remove GitHub entries from `~/.ssh/config`
- Remove SSH keys from ssh-agent
- **NOT** delete your Git repos (your code is safe)

After reset, run `./github-multi-setup.sh` again to start fresh.

---

## 🧠 How It Works (For the Curious)

1. **systemd ssh-agent**: Single agent manages all keys, survives reboots
2. **SSH Config Host Aliases**: `github-personal` maps to `github.com` with specific key
3. **IdentitiesOnly**: Forces SSH to only use the specified key (no trial-and-error)
4. **Conditional Git Config**: Auto-switches identity based on project directory

It's elegant, it's predictable, it's the Arch way.

---

## 🎓 Pro Tips

- **Use descriptive commit messages**: Future you will thank present you
- **Keep personal and work projects separate**: Don't accidentally push company code to your personal GitHub
- **Enable 2FA on all GitHub accounts**: Because security
- **Backup your SSH keys**: Store them somewhere safe (encrypted USB, password manager)

---

## 📚 Additional Resources

- [GitHub SSH Documentation](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)
- [Arch Wiki: SSH Keys](https://wiki.archlinux.org/title/SSH_keys)
- [Git Config Conditional Includes](https://git-scm.com/docs/git-config#_conditional_includes)

---

## 🐛 Known Issues

None yet. If you find one, congrats! You're the QA team now.

---

## 🤝 Contributing

Found a bug? Have a suggestion? Want to add support for 47 GitHub accounts because you're a serial org-creator?

Feel free to open an issue or PR. Just remember: **simplicity over features**.

---

## 📜 License

Do whatever you want with this. It's a bash script, not the Mona Lisa.

---

## 🙏 Credits

- **Arch Linux**: For being Arch Linux
- **systemd**: For making ssh-agent not suck
- **GitHub**: For making us juggle multiple accounts in the first place
- **You**: For reading this far. You're doing great.

---

**Now go forth and commit with confidence, you beautiful multi-account maestro.** 🎭

*P.S. - Don't forget to tell everyone you use Arch btw.*
