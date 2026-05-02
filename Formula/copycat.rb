class Copycat < Formula
  desc "Cross-platform clipboard CLI and C ABI library written in Zig"
  homepage "https://github.com/georgemandis/copycat"
  version "0.2.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/copycat/releases/download/v0.2.0/copycat-v0.2.0-macos-aarch64.tar.gz"
      sha256 "a8edb08a0e29f6ca0a117c9a327a7fe5bc9ace670601a193b90aaf83b4c4b05c"
    else
      url "https://github.com/georgemandis/copycat/releases/download/v0.2.0/copycat-v0.2.0-macos-x86_64.tar.gz"
      sha256 "c0e1d5e68aa90c11c914a77843302ba2c4e9618d2d329163cf74a3780be2363c"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/copycat/releases/download/v0.2.0/copycat-v0.2.0-linux-aarch64.tar.gz"
      sha256 "2a3029a04686655b19dca2b9b0f3659469a10a34fdfefe5daebe5d802d40d441"
    else
      url "https://github.com/georgemandis/copycat/releases/download/v0.2.0/copycat-v0.2.0-linux-x86_64.tar.gz"
      sha256 "181af4adb52b2531da0b0d5225bf26fd91d667ff75028e873615ee427aca8c8b"
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
