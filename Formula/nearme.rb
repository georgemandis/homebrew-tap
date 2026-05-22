class Nearme < Formula
  desc "Search for places near you from the command line using native macOS APIs"
  homepage "https://github.com/georgemandis/nearme"
  version "0.1.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/nearme/releases/download/v0.1.0/nearme-v0.1.0-macos-aarch64.tar.gz"
      sha256 "6e6e62540fffb008c9e894898e916b0553d6eace80930e7a47d929a78cf17db9"
    else
      url "https://github.com/georgemandis/nearme/releases/download/v0.1.0/nearme-v0.1.0-macos-x86_64.tar.gz"
      sha256 "56241b72e3923dc32ffe8a66ba37e2f69f448cb3e9c1386de6c0e201cce2db73"
    end
  end

  def install
    bin.install "nearme"
  end

  test do
    assert_match "Usage: nearme", shell_output("#{bin}/nearme --help")
  end
end
