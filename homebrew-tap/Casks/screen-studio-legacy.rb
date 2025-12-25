cask "screen-studio-legacy" do
  arch arm: "-arm64"

  version "2.26.0-3206"
  sha256 arm:   "550b7d20b41153e4d869ae086e459828a10c83f6935b9f226b4aaf682a60c417",
         intel: "203d64cf3dd155d60f29f0600d3b28c63d1efcd2e52ebe828ea1f75b159f471c"

  url "https://screenstudioassets.com/releases/#{version}/Screen%20Studio-#{version}#{arch}-mac.zip",
      verified: "screenstudioassets.com/"
  name "Screen Studio"
  desc "Screen recorder and editor (legacy 2.26.0 for lifetime license)"
  homepage "https://screen.studio/"

  # Disable auto-updates to preserve this version
  auto_updates false

  app "Screen Studio.app"

  zap trash: [
        "~/Library/Application Support/com.apple.sharedfilelist/com.apple.LSSharedFileList.ApplicationRecentDocuments/com.timpler.screenstudio.sfl*",
        "~/Library/Application Support/Screen Studio",
        "~/Library/Caches/com.timpler.screenstudio",
        "~/Library/Caches/com.timpler.screenstudio.ShipIt",
        "~/Library/HTTPStorages/com.timpler.screenstudio",
        "~/Library/Preferences/com.timpler.screenstudio.plist",
        "~/Library/Saved Application State/com.timpler.screenstudio.savedState",
      ],
      rmdir: "~/Screen Studio Projects"
end
