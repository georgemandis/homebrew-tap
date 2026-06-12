class Spectacle < Formula
  desc "Screen and system audio capture CLI using native OS APIs"
  homepage "https://github.com/georgemandis/spectacle"
  version "0.2.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/spectacle/releases/download/v0.2.0/spectacle-v0.2.0-macos-aarch64.tar.gz"
      sha256 "794dd040f94aef559a30506b82e9b8ff9710c4dca43fb0c54e3bac5940c0b22b"
    else
      url "https://github.com/georgemandis/spectacle/releases/download/v0.2.0/spectacle-v0.2.0-macos-x86_64.tar.gz"
      sha256 "59ddacbfe8803e445c94f9b068df8d4218c7f6e8f6d161f246b47f67528db5c0"
    end
  end

  def install
    bin.install "spectacle"
  end

  test do
    assert_match "spectacle", shell_output("#{bin}/spectacle --version")
  end
end
