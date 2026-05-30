class Fulton < Formula
  desc "Cross-platform global keyboard shortcut daemon and C ABI library written in Zig"
  homepage "https://github.com/georgemandis/fulton"
  version "0.1.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/fulton/releases/download/v0.1.1/fulton-v0.1.1-macos-aarch64.tar.gz"
      sha256 "f8c1eb004af6d6bf5c0d191f41082500e8d1e89314042f9a115a400c613273e6"
    else
      url "https://github.com/georgemandis/fulton/releases/download/v0.1.1/fulton-v0.1.1-macos-x86_64.tar.gz"
      sha256 "2681eef64407a8bb1aee2c5868f6980b749ad4f83aa6aeaac324bd383a963a62"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/fulton/releases/download/v0.1.1/fulton-v0.1.1-linux-aarch64.tar.gz"
      sha256 "4bd3905e926f4fef4b3c5c64e5f7b5af5895ae05c0ae5c775561a49eab6a2311"
    else
      url "https://github.com/georgemandis/fulton/releases/download/v0.1.1/fulton-v0.1.1-linux-x86_64.tar.gz"
      sha256 "75a418dd425b565035d70036a456ddfd9451728eac61e5da88aae443c03c820d"
    end
  end

  def install
    bin.install "fulton"
  end

  test do
    assert_match "Usage: fulton", shell_output("#{bin}/fulton --help")
  end
end
