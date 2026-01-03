cask "quotio" do
  version "0.4.4"
  sha256 "753161726375b9b4aa11595ab584227f026c2417c7cd6cfc80e95994e945de7f"

  url "https://github.com/nguyenphutrong/quotio/releases/download/v#{version}/Quotio-#{version}.dmg",
      verified: "github.com/nguyenphutrong/quotio/"
  name "Quotio"
  desc "Menu bar app for managing CLIProxyAPI quotas and providers"
  homepage "https://github.com/nguyenphutrong/quotio"

  depends_on macos: ">= :sequoia"

  # Disable auto-updates to preserve this version
  auto_updates false

  app "Quotio.app"

  zap trash: [
    "~/Library/Application Support/Quotio",
    "~/Library/Application Support/proseek.io.vn.Quotio",
    "~/Library/Caches/proseek.io.vn.Quotio",
    "~/Library/Preferences/proseek.io.vn.Quotio.plist",
    "~/Library/Saved Application State/proseek.io.vn.Quotio.savedState",
  ]
end

