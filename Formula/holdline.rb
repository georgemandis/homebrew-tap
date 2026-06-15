class Holdline < Formula
  desc "Freeze merges across your GitHub org from the terminal"
  homepage "https://github.com/georgemandis/little-money-ideas"
  # tag_prefix: holdline-v
  version "0.1.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/little-money-ideas/releases/download/holdline-v0.1.0/holdline-v0.1.0-macos-aarch64.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    else
      url "https://github.com/georgemandis/little-money-ideas/releases/download/holdline-v0.1.0/holdline-v0.1.0-macos-x86_64.tar.gz"
      sha256 "0000000000000000000000000000000000000000000000000000000000000000"
    end
  end

  on_linux do
    url "https://github.com/georgemandis/little-money-ideas/releases/download/holdline-v0.1.0/holdline-v0.1.0-linux-x86_64.tar.gz"
    sha256 "0000000000000000000000000000000000000000000000000000000000000000"
  end

  def install
    bin.install "holdline"

    generate_completions_from_executable(bin/"holdline", "completions")
  end

  test do
    assert_match "holdline v", shell_output("#{bin}/holdline --version")
  end
end
