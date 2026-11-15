class Loupe < Formula
  desc "Computer vision CLI for face detection, OCR, and barcode scanning"
  homepage "https://github.com/georgemandis/loupe"
  version "0.6.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/loupe/releases/download/v0.6.1/loupe-v0.6.1-macos-aarch64.tar.gz"
      sha256 "dfa7464b4ab4cefab8364a2706eff0058abf1ae49e9215cf41713381f4a31056"
    else
      url "https://github.com/georgemandis/loupe/releases/download/v0.6.1/loupe-v0.6.1-macos-x86_64.tar.gz"
      sha256 "726387ae30210747b857ae952340eacdd402a2f127bc1224800868b6acb95e1f"
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
