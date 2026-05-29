class Tezcatl < Formula
  desc "Lightweight CLI for rendering web pages using native macOS WebKit"
  homepage "https://github.com/georgemandis/tezcatl"
  version "0.1.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/tezcatl/releases/download/v0.1.0/tezcatl-v0.1.0-macos-aarch64.tar.gz"
      sha256 "PLACEHOLDER"
    else
      url "https://github.com/georgemandis/tezcatl/releases/download/v0.1.0/tezcatl-v0.1.0-macos-x86_64.tar.gz"
      sha256 "PLACEHOLDER"
    end
  end

  def install
    bin.install "tezcatl"
  end

  test do
    assert_match "Usage: tezcatl", shell_output("#{bin}/tezcatl --help")
  end
end
