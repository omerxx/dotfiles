#!/usr/bin/env bash
# Source: github.com/Kcraft059/sketchybar-config

__icon_map() {
    case "$1" in
    "Brave Browser") icon_result=":brave_browser:" ;;
    "Keyboard Maestro") icon_result=":keyboard_maestro:" ;;
    "Final Cut Pro") icon_result=":final_cut_pro:" ;;
    "FaceTime") icon_result=":face_time:" ;;
    "Messages" | "Nachrichten") icon_result=":messages:" ;;
    "Tweetbot" | "Twitter") icon_result=":twitter:" ;;
    "ChatGPT") icon_result=":openai:" ;;
    "Microsoft Edge") icon_result=":microsoft_edge:" ;;
    "VLC") icon_result=":vlc:" ;;
    "Notes") icon_result=":notes:" ;;
    "WhatsApp") icon_result=":whats_app:" ;;
    "GitHub Desktop" | "GitHub") icon_result=":git_hub:" ;;
    "App Store") icon_result=":app_store:" ;;
    "Chromium" | "Google Chrome" | "Google Chrome Canary") icon_result=":google_chrome:" ;;
    "zoom.us") icon_result=":zoom:" ;;
    "Microsoft Word") icon_result=":microsoft_word:" ;;
    "Microsoft Teams") icon_result=":microsoft_teams:" ;;
    "WebStorm") icon_result=":web_storm:" ;;
    "Neovide" | "MacVim" | "Vim" | "VimR") icon_result=":vim:" ;;
    "Sublime Text") icon_result=":sublime_text:" ;;
    "TextEdit") icon_result=":textedit:" ;;
    "Notion") icon_result=":notion:" ;;
    "Calendar" | "Fantastical") icon_result=":calendar:" ;;
    "Android Studio") icon_result=":android_studio:" ;;
    "Calculator") icon_result=":calculator:" ;;
    "Xcode") icon_result=":xcode:" ;;
    "Slack") icon_result=":slack:" ;;
    "Bitwarden") icon_result=":bit_warden:" ;;
    "System Preferences" | "System Settings") icon_result=":gear:" ;;
    "Discord" | "Discord Canary" | "Discord PTB") icon_result=":discord:" ;;
    "Vivaldi") icon_result=":vivaldi:" ;;
    "Firefox") icon_result=":firefox:" ;;
    "Firefox Developer Edition" | "Firefox Nightly") icon_result=":firefox_developer_edition:" ;;
    "Canary Mail" | "HEY" | "Mail" | "Mailspring" | "MailMate" | "Outlook") icon_result=":mail:" ;;
    "Safari" | "Safari Technology Preview") icon_result=":safari:" ;;
    "Telegram") icon_result=":telegram:" ;;
    "Spotify") icon_result=":spotify:" ;;
    "Figma") icon_result=":figma:" ;;
    "Music") icon_result=":music:" ;;
    "Obsidian") icon_result=":obsidian:" ;;
    "Reminders") icon_result=":reminders:" ;;
    "Preview" | "Skim") icon_result=":pdf:" ;;
    "1Password" | "1Password 7") icon_result=":one_password:" ;;
    "Passwords") icon_result=":passwords:" ;;
    "Shortcuts") icon_result=":shortcuts:" ;;
    "Code" | "Code - Insiders") icon_result=":code:" ;;
    "VSCodium") icon_result=":vscodium:" ;;
    "Windsurf") icon_result=":code:" ;;
    "Finder") icon_result=":finder:" ;;
    "Linear") icon_result=":linear:" ;;
    "Signal") icon_result=":signal:" ;;
    "Podcasts") icon_result=":podcasts:" ;;
    "Alacritty" | "Hyper" | "iTerm2" | "kitty" | "Terminal" | "WezTerm" | "Ghostty") icon_result=":terminal:" ;;
    "Activity Monitor") icon_result=":activity_monitor:" ;;
    "Arc") icon_result=":arc:" ;;
    "Steam") icon_result=":steam:" ;;
    "Weather") icon_result=":weather:" ;;
    *) icon_result=":default:" ;;
    esac
}
