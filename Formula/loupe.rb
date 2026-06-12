class Loupe < Formula
  desc "Computer vision CLI for face detection, OCR, and barcode scanning"
  homepage "https://github.com/georgemandis/loupe"
  version "0.4.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/loupe/releases/download/v0.4.0/loupe-v0.4.0-macos-aarch64.tar.gz"
      sha256 "d3308eb8042072c5c1251b0bf9c529b1c612f19cd7e6107125e91747cdf3a616"
    else
      url "https://github.com/georgemandis/loupe/releases/download/v0.4.0/loupe-v0.4.0-macos-x86_64.tar.gz"
      sha256 "4bdf23202f2bf9272a9483fdabbcff3dc9d6c6c2e8a4b92ac64acdf6ae477292"
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
