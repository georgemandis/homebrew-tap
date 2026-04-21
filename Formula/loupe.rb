class Loupe < Formula
  desc "Computer vision CLI — detect faces, read text, and scan barcodes using native OS APIs"
  homepage "https://github.com/georgemandis/loupe"
  version "0.1.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/loupe/releases/download/v0.1.0/loupe-v0.1.0-macos-aarch64.tar.gz"
      sha256 "857c18befb144e5627818b5ad240c6e4a2a0cc16b11f5efde3391e1feb5ba693"
    else
      url "https://github.com/georgemandis/loupe/releases/download/v0.1.0/loupe-v0.1.0-macos-x86_64.tar.gz"
      sha256 "9502b00e0492675cc6477e811a4a20946d4e9f74c6d98a9b64339f858b6b3070"
    end
  end

  def install
    bin.install "loupe"
  end

  test do
    assert_match "Usage: loupe", shell_output("#{bin}/loupe --help")
  end
end
