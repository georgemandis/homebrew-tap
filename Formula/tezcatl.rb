class Tezcatl < Formula
  desc "Lightweight CLI for rendering web pages using native macOS WebKit"
  homepage "https://github.com/georgemandis/tezcatl"
  version "0.1.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/tezcatl/releases/download/v0.1.0/tezcatl-v0.1.0-macos-aarch64.tar.gz"
      sha256 "ff3f87c871da72a10fb36925f5d88e9741fd8eb29bd32a9c5c47164360409e25"
    else
      url "https://github.com/georgemandis/tezcatl/releases/download/v0.1.0/tezcatl-v0.1.0-macos-x86_64.tar.gz"
      sha256 "b529139cf59e9eb9dead262fc33519a1a5174be7a8a258c6eefd3bb54927268c"
    end
  end

  def install
    bin.install "tezcatl"
  end

  test do
    assert_match "Usage: tezcatl", shell_output("#{bin}/tezcatl --help")
  end
end
