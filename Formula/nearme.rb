class Nearme < Formula
  desc "Search for places near you from the command line using native macOS APIs"
  homepage "https://github.com/georgemandis/nearme"
  version "0.1.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/nearme/releases/download/v0.1.0/nearme-v0.1.0-macos-aarch64.tar.gz"
      sha256 "PLACEHOLDER"
    else
      url "https://github.com/georgemandis/nearme/releases/download/v0.1.0/nearme-v0.1.0-macos-x86_64.tar.gz"
      sha256 "PLACEHOLDER"
    end
  end

  def install
    bin.install "nearme"
  end

  test do
    assert_match "Usage: nearme", shell_output("#{bin}/nearme --help")
  end
end
