# macOS Apps Configuration Guide

Manual configuration steps for apps that cannot be automated via Nix/Homebrew.

---

## Priority Apps (Configure First)

These apps are foundational - configure them before other apps since they unlock access to credentials, notes, and communication.

### 1. 1Password

**Why first:** Stores all credentials needed for other app logins.

**Setup:**
1. Download from App Store or use Homebrew cask
2. Sign in with your 1Password account
3. Enable Safari/browser extension
4. Enable "Unlock using Touch ID"

**Backup/Restore:** Cloud-synced automatically via 1Password account.

---

### 2. Obsidian

**Why second:** Access to your knowledge base and setup notes.

**Setup:**
1. Open Obsidian
2. "Open folder as vault" → Navigate to iCloud Drive
   - Path: `~/Library/Mobile Documents/iCloud~md~obsidian/Documents/<vault-name>`
3. Trust the vault when prompted
4. Wait for iCloud sync to complete (may take a while for large vaults)

**Backup/Restore:**
- Vault synced via iCloud automatically
- Plugin settings stored in `.obsidian/` folder within vault
- Community plugins may need re-authentication (if using Obsidian Sync, etc.)

---

### 3. Telegram

**Why third:** Communication and 2FA codes access.

**Setup:**
1. Open Telegram
2. Sign in with phone number
3. Verify with code (sent to other devices or SMS)

**Backup/Restore:** Cloud-synced automatically. Chat history syncs from Telegram servers.

---

## Apps Requiring Manual Restoration

These apps store configurations locally or use proprietary sync that needs setup.

### Raycast

**Backup location:** `~/.config/raycast/` (partial) + Raycast account sync

**To backup:**
1. Raycast → Settings → Advanced → Export
2. Save the `.rayconfig` file somewhere safe (iCloud, Git, etc.)

**To restore:**
1. Raycast → Settings → Advanced → Import
2. Select your `.rayconfig` file
3. Re-authenticate extensions that require API keys:
   - GitHub
   - Linear
   - Notion
   - etc.

**Extensions to reinstall:** Extensions are listed in the config but may need:
- Manual re-installation from store
- API key re-entry
- OAuth re-authentication

**Recommended extensions:** (document your preferred ones here)
- Clipboard History
- Window Management
- ...

---

### Arc Browser

**Backup/Restore:**
- Sign in with Arc account to restore:
  - Spaces and folders
  - Pinned tabs
  - Boosts (custom CSS)
- Extensions need manual reinstall

---

### VS Code / Cursor

**Backup/Restore:**
1. Sign in with GitHub/Microsoft account
2. Enable Settings Sync
3. Extensions, keybindings, and settings restore automatically

**Manual items:**
- Workspace-specific settings
- Local extensions not from marketplace

---

### Alfred / Raycast Snippets

If migrating from Alfred or have text snippets:
- Export from source app
- Import into Raycast or new tool

---

## Apps with Built-in Cloud Sync

These sync automatically once signed in:

| App | Sync Method | What Syncs |
|-----|-------------|------------|
| 1Password | 1Password Account | Everything |
| Obsidian | iCloud/Obsidian Sync | Vault content |
| Telegram | Telegram Cloud | Chats, stickers |
| Notion | Notion Account | All workspaces |
| Figma | Figma Account | All designs |
| Spotify | Spotify Account | Playlists, library |
| Bear | iCloud | Notes |
| Things 3 | Things Cloud | Tasks |

---

## Apps Requiring macOS Settings

Some apps need permissions granted manually:

```bash
# Open Accessibility settings
open "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility"

# Open Full Disk Access
open "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles"
```

**Accessibility access needed by:**
- AeroSpace
- skhd
- Hammerspoon
- Raycast
- Karabiner-Elements

**Full Disk Access needed by:**
- Terminal/iTerm/Ghostty (for some operations)
- Backup applications

---

## Configuration Backup Strategies

### Option 1: Git (for config files)
```bash
# Add config files to dotfiles repo
cp ~/.config/raycast/config.json ~/dotfiles/raycast/

# For sensitive files, use git-crypt or store separately
```

### Option 2: iCloud Drive
Store exports in: `~/Library/Mobile Documents/com~apple~CloudDocs/App Configs/`

### Option 3: Mackup
```bash
brew install mackup
mackup backup   # Backs up app configs to iCloud/Dropbox
mackup restore  # Restores on new machine
```

**Mackup supported apps:** https://github.com/lra/mackup#supported-applications

### Option 4: Export Files
Keep a folder of `.rayconfig`, `.json` exports for manual restoration.

---

## Post-Install Checklist

After running dotfiles bootstrap:

- [ ] Sign into 1Password
- [ ] Open Obsidian vault from iCloud
- [ ] Sign into Telegram
- [ ] Import Raycast config
- [ ] Sign into browsers (Arc, Safari, Firefox)
- [ ] Grant Accessibility permissions
- [ ] Sign into VS Code/Cursor for Settings Sync
- [ ] Verify cloud apps are syncing (Notion, Figma, etc.)

---

## Notes

_Add your app-specific notes here as you configure them._
