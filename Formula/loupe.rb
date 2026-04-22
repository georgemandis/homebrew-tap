class Loupe < Formula
  desc "Computer vision CLI — detect faces, read text, and scan barcodes using native OS APIs"
  homepage "https://github.com/georgemandis/loupe"
  version "0.2.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/loupe/releases/download/v0.2.0/loupe-v0.2.0-macos-aarch64.tar.gz"
      sha256 "0df52b4113fc5c93b4512ef97669cd0e09c008fe752d459cda001c927635a710"
    else
      url "https://github.com/georgemandis/loupe/releases/download/v0.2.0/loupe-v0.2.0-macos-x86_64.tar.gz"
      sha256 "14c20103fbd55631e72bce22f17ccf347365d45a8b07a2ea16081efe9c289234"
    end
  end

  def install
    bin.install "loupe"
  end

  test do
    assert_match "Usage: loupe", shell_output("#{bin}/loupe --help")
  end
end
