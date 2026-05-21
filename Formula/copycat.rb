class Copycat < Formula
  desc "Cross-platform clipboard CLI and C ABI library written in Zig"
  homepage "https://github.com/georgemandis/copycat"
  version "0.3.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/copycat/releases/download/v0.3.0/copycat-v0.3.0-macos-aarch64.tar.gz"
      sha256 "5e7eb9f22e2c432f4cad42b42559a2d6a74881fb68cee8e4e26181e82d17e6d8"
    else
      url "https://github.com/georgemandis/copycat/releases/download/v0.3.0/copycat-v0.3.0-macos-x86_64.tar.gz"
      sha256 "28fbc7658d547e89236abdaaf885154e65832b32a4aed0362994db8e9dbe0a2c"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/copycat/releases/download/v0.3.0/copycat-v0.3.0-linux-aarch64.tar.gz"
      sha256 "b65223b57e2a9b5fe1cbfdd859c9556341c768426ebe41430c6f9f36ac4bdebe"
    else
      url "https://github.com/georgemandis/copycat/releases/download/v0.3.0/copycat-v0.3.0-linux-x86_64.tar.gz"
      sha256 "5852fc82abf1de3b09d0400d470015ee8603cc0b4f1860ee484dc540f818762e"
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
