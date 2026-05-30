class Copycat < Formula
  desc "Cross-platform clipboard CLI and C ABI library written in Zig"
  homepage "https://github.com/georgemandis/copycat"
  version "0.4.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/copycat/releases/download/v0.4.0/copycat-v0.4.0-macos-aarch64.tar.gz"
      sha256 "69446a67901d1c9b3e49adbd32304f2d8e960b5b7c8e6d7ddd42bc7031725d3e"
    else
      url "https://github.com/georgemandis/copycat/releases/download/v0.4.0/copycat-v0.4.0-macos-x86_64.tar.gz"
      sha256 "8f55ff8ac8f53e8ebfbb39c7936ec95e5a02e058568febc76120e978e0e45ce9"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/copycat/releases/download/v0.4.0/copycat-v0.4.0-linux-aarch64.tar.gz"
      sha256 "f0114c9799704f3a549fb3e9b58b5d9978073f8dc1afa2a89bad349bd8377da7"
    else
      url "https://github.com/georgemandis/copycat/releases/download/v0.4.0/copycat-v0.4.0-linux-x86_64.tar.gz"
      sha256 "0d2b5708fd0c1dc363eef0a620f4f2238617d223de47ded80e5a1f4b89c54291"
    end
  end

  def install
    bin.install "copycat"

    generate_completions_from_executable(bin/"copycat", "completions")
  end

  test do
    assert_match "Usage: copycat", shell_output("#{bin}/copycat --help")
  end
end
