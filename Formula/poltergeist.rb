class Poltergeist < Formula
  desc "Cross-platform accessibility CLI for inspecting UI elements and managing windows"
  homepage "https://github.com/georgemandis/poltergeist"
  version "0.1.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/poltergeist/releases/download/v0.1.0/poltergeist-v0.1.0-macos-aarch64.tar.gz"
      sha256 "1770222e04d7ead50c8ed3ddc2ed465a47f005e1b3d1c38bcce36031060ced03"
    else
      url "https://github.com/georgemandis/poltergeist/releases/download/v0.1.0/poltergeist-v0.1.0-macos-x86_64.tar.gz"
      sha256 "19364b699fdd6a7c795110471c222bcdaf25f12f9eb078a8a0cc11852859c814"
    end
  end

  def install
    bin.install "poltergeist"
  end

  def caveats
    <<~EOS
      Poltergeist requires Accessibility permission.
      Grant access in System Settings > Privacy & Security > Accessibility.
    EOS
  end

  test do
    assert_match "poltergeist", shell_output("#{bin}/poltergeist --version")
  end
end
