class Tezcatl < Formula
  desc "Lightweight CLI for rendering web pages using native macOS WebKit"
  homepage "https://github.com/georgemandis/tezcatl"
  version "0.1.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/tezcatl/releases/download/v0.1.0/tezcatl-v0.1.0-macos-aarch64.tar.gz"
      sha256 "a28b0f92b512a9972d8ade2b047403ba907313c94be3a4adbdd2ae5c1f7bac12"
    else
      url "https://github.com/georgemandis/tezcatl/releases/download/v0.1.0/tezcatl-v0.1.0-macos-x86_64.tar.gz"
      sha256 "c7241caa91ced895c9074acb99f115ffc91073140614d19488a4ab92c167d2ca"
    end
  end

  def install
    bin.install "tezcatl"
  end

  test do
    assert_match "Usage: tezcatl", shell_output("#{bin}/tezcatl --help")
  end
end
