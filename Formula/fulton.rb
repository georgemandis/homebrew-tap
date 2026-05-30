class Fulton < Formula
  desc "Cross-platform global keyboard shortcut daemon and C ABI library written in Zig"
  homepage "https://github.com/georgemandis/fulton"
  version "0.1.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/fulton/releases/download/v0.1.0/fulton-v0.1.0-macos-aarch64.tar.gz"
      sha256 "794849776d5df37ccee31e9ba800ba5a6de2edf3da2c60c9baea15b2a8ada994"
    else
      url "https://github.com/georgemandis/fulton/releases/download/v0.1.0/fulton-v0.1.0-macos-x86_64.tar.gz"
      sha256 "47adbe591e8053caaafc9940b841ad23b51c6a8f42d290f542499cdf28a7b07b"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/fulton/releases/download/v0.1.0/fulton-v0.1.0-linux-aarch64.tar.gz"
      sha256 "a39fc0dca4b8704947ff6b4a1305b0cc09e13f4f70d219c5dd046b90a25fdf6c"
    else
      url "https://github.com/georgemandis/fulton/releases/download/v0.1.0/fulton-v0.1.0-linux-x86_64.tar.gz"
      sha256 "e9bd6355e241670c00bc07f87fedb3d43442c711882dce7e4d9663e9c767c3d9"
    end
  end

  def install
    bin.install "fulton"
  end

  test do
    assert_match "Usage: fulton", shell_output("#{bin}/fulton --help")
  end
end
