class Copycat < Formula
  desc "A cross-platform clipboard CLI and C ABI library written in Zig"
  homepage "https://github.com/georgemandis/copycat"
  version "0.1.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/copycat/releases/download/v0.1.1/copycat-v0.1.1-macos-aarch64.tar.gz"
      sha256 "e326218e6822593747c5f32b948f7998ed06b0062bb0f29ca2ca3d642bbf6a15"
    else
      url "https://github.com/georgemandis/copycat/releases/download/v0.1.1/copycat-v0.1.1-macos-x86_64.tar.gz"
      sha256 "bee3b6aa6ea88f8b0917029091f571db49753d5778e86aa8d9ba1cc0e3a864ab"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/copycat/releases/download/v0.1.1/copycat-v0.1.1-linux-aarch64.tar.gz"
      sha256 "d64205f95aa5772374bca9c03bee5b9fc39f3fe518b28f4cccdb8d9d81638b70"
    else
      url "https://github.com/georgemandis/copycat/releases/download/v0.1.1/copycat-v0.1.1-linux-x86_64.tar.gz"
      sha256 "f432dc0be4b234c5cfca74ce43b35a2fd18feab02fe6b86c3e4b1e149ad1e3ee"
    end
  end

  def install
    bin.install "copycat"
  end

  test do
    assert_match "Usage: copycat", shell_output("#{bin}/copycat --help")
  end
end
