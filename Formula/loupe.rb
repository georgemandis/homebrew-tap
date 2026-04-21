class Loupe < Formula
  desc "Computer vision CLI — detect faces, read text, and scan barcodes using native OS APIs"
  homepage "https://github.com/georgemandis/loupe"
  version "0.1.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/loupe/releases/download/v0.1.1/loupe-v0.1.1-macos-aarch64.tar.gz"
      sha256 "766fa8b54040c0325a3c7b442f1e895a2ae883a67abaf267d85adfac1a69e5f8"
    else
      url "https://github.com/georgemandis/loupe/releases/download/v0.1.1/loupe-v0.1.1-macos-x86_64.tar.gz"
      sha256 "ef1c8ed41dd3da7a9de1785a222c5412f529e668af50a678b26897af0f5df078"
    end
  end

  def install
    bin.install "loupe"
  end

  test do
    assert_match "Usage: loupe", shell_output("#{bin}/loupe --help")
  end
end
