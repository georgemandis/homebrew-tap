class Loupe < Formula
  desc "Computer vision CLI for face detection, OCR, and barcode scanning"
  homepage "https://github.com/georgemandis/loupe"
  version "0.6.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/loupe/releases/download/v0.6.0/loupe-v0.6.0-macos-aarch64.tar.gz"
      sha256 "2a959d98d14826023cdbffe2f95a80c87d1e1599690b8c17e25be627f340d49a"
    else
      url "https://github.com/georgemandis/loupe/releases/download/v0.6.0/loupe-v0.6.0-macos-x86_64.tar.gz"
      sha256 "3c45b0b48fe80580a7ffe5be1d916b31989158f9a740d2d9c5fe553175841dad"
    end
  end

  def install
    bin.install "loupe"

    generate_completions_from_executable(bin/"loupe", "completions")
  end

  test do
    assert_match "Usage: loupe", shell_output("#{bin}/loupe --help")
  end
end
