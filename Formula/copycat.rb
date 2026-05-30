class Copycat < Formula
  desc "Cross-platform clipboard CLI and C ABI library written in Zig"
  homepage "https://github.com/georgemandis/copycat"
  version "0.4.2"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/copycat/releases/download/v0.4.2/copycat-v0.4.2-macos-aarch64.tar.gz"
      sha256 "f485007004a43fd2f0ec814a39e56dc763c3c6c9c8580ef347b082eb426c8567"
    else
      url "https://github.com/georgemandis/copycat/releases/download/v0.4.2/copycat-v0.4.2-macos-x86_64.tar.gz"
      sha256 "3c3d2c00285b39116070a8a97274b0b74fd284a739b370bc1e20fb3f54fc2f00"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/copycat/releases/download/v0.4.2/copycat-v0.4.2-linux-aarch64.tar.gz"
      sha256 "5c6970982abc631457814de8509dbab002c946e486217917b6db60de35c6f77e"
    else
      url "https://github.com/georgemandis/copycat/releases/download/v0.4.2/copycat-v0.4.2-linux-x86_64.tar.gz"
      sha256 "e033178983c387ff5431f1ad46dd80bab74c755cbe5553baf8aa746c7e7684b3"
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
