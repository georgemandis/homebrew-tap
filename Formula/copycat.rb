class Copycat < Formula
  desc "A cross-platform clipboard CLI and C ABI library written in Zig"
  homepage "https://github.com/georgemandis/copycat"
  version "0.1.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/copycat/releases/download/v0.1.0/copycat-v0.1.0-macos-aarch64.tar.gz"
      sha256 "c2509e15fd994a2dd3ceede41d8332a0245bd463cf10f2492b6a36be5254ad75"
    else
      url "https://github.com/georgemandis/copycat/releases/download/v0.1.0/copycat-v0.1.0-macos-x86_64.tar.gz"
      sha256 "9f8007d7a7988389a8d9123ba18b4862c39dff60a7cc2da77184407a794ae189"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/copycat/releases/download/v0.1.0/copycat-v0.1.0-linux-aarch64.tar.gz"
      sha256 "2330d8c2085339a1adfda2e8d22a036026f17a72582b744e17aea0844c5d3dee"
    else
      url "https://github.com/georgemandis/copycat/releases/download/v0.1.0/copycat-v0.1.0-linux-x86_64.tar.gz"
      sha256 "f051b47f35729cf54b8d7d31081b6befac9e963ba7cc5b57652aad336d3e1fb7"
    end
  end

  def install
    bin.install "copycat"
  end

  test do
    assert_match "Usage: copycat", shell_output("#{bin}/copycat --help")
  end
end
