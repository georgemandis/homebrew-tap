class Spectacle < Formula
  desc "Screen and system audio capture CLI using native OS APIs"
  homepage "https://github.com/georgemandis/spectacle"
  version "0.1.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/spectacle/releases/download/v0.1.0/spectacle-v0.1.0-macos-aarch64.tar.gz"
      sha256 "fcb384c603f9f56c729c9d7546e6dc468763ab5292dced30e441e355648da4e6"
    end
  end

  def install
    bin.install "spectacle"
  end

  test do
    assert_match "spectacle", shell_output("#{bin}/spectacle --version")
  end
end
