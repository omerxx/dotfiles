# macOS Apps Configuration Guide

Manual configuration steps for apps that cannot be automated via Nix/Homebrew.

---

## Priority Apps (Configure First)

These apps are foundational - configure them before other apps since they unlock access to credentials, notes, and communication.

### 1. 1Password

**Why first:** Stores all credentials and SSH keys needed for other app logins and GitHub.

**Setup:**
1. Open 1Password (installed by nix-darwin)
2. Sign in with your 1Password account
3. Enable Safari/browser extension
4. Enable "Unlock using Touch ID"

**Enable SSH Agent (for GitHub):**
1. 1Password → Settings → Developer
2. Enable "Use the SSH agent"
3. Enable "Integrate with 1Password CLI"

**Add SSH Key for GitHub:**
1. In 1Password: Create new item → SSH Key
2. Generate a new key or import existing
3. Copy the public key
4. Add to GitHub: https://github.com/settings/ssh/new

**Then run:**
```bash
./setup.sh --github
```

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

## Apps to Launch First (Enable Auto-Start)

These apps are installed by nix-darwin but need to be opened once to enable "Start at Login":

| App | Action |
|-----|--------|
| Raycast | Settings → Enable "Launch at Login" |
| AeroSpace | Settings → Enable "Start at Login" |
| Hammerspoon | Preferences → Enable "Launch Hammerspoon at login" |
| Itsycal | Preferences → Enable "Launch at Login" |
| Gitify | Settings → Enable auto-start |
| LinearMouse | Settings → Enable "Launch at Login" |
| xbar | Preferences → Enable "Start at Login" |

**Managed by brew services (auto-start already configured):**
- sketchybar
- skhd
- borders

---

## Apps Requiring Manual Restoration

These apps store configurations locally or use proprietary sync that needs setup.

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

## Post-Install Checklist

After running dotfiles bootstrap:

- [ ] Sign into 1Password + enable SSH agent
- [ ] Run `./setup.sh --github`
- [ ] Open Obsidian vault from iCloud
- [ ] Sign into Telegram
- [ ] Launch and enable auto-start: Raycast, AeroSpace, Hammerspoon, etc.
- [ ] Grant Accessibility permissions
- [ ] Sign into browsers and other apps

---

## Screen Studio (Legacy 2.26.0)

Screen Studio is installed manually using a custom local cask to preserve the lifetime license version (2.26.0).

**Install:**
```bash
brew install --cask ~/dotfiles/homebrew-tap/Casks/screen-studio-legacy.rb
```

**Important:**
- Do NOT update Screen Studio through the app or Homebrew
- Version 2.26.0 is the last version covered by lifetime license
- The cask has `auto_updates false` to prevent automatic upgrades

**Reinstall if needed:**
```bash
brew uninstall --cask screen-studio-legacy
brew install --cask ~/dotfiles/homebrew-tap/Casks/screen-studio-legacy.rb
```

---

## Notes

_Add your app-specific notes here as you configure them._
