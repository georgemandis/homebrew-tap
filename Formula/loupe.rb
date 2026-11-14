class Loupe < Formula
  desc "Computer vision CLI for face detection, OCR, and barcode scanning"
  homepage "https://github.com/georgemandis/loupe"
  version "0.5.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/loupe/releases/download/v0.5.0/loupe-v0.5.0-macos-aarch64.tar.gz"
      sha256 "784eafc5975dad3674d48c24a82d5d66016ac71dc57065c61b6f11ba74255bad"
    else
      url "https://github.com/georgemandis/loupe/releases/download/v0.5.0/loupe-v0.5.0-macos-x86_64.tar.gz"
      sha256 "b91607c2db5008887a4808aa742784b4481cd12780feb4d81f2b1a56873120ab"
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
