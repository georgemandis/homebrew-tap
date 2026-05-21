class Loupe < Formula
  desc "Computer vision CLI for face detection, OCR, and barcode scanning"
  homepage "https://github.com/georgemandis/loupe"
  version "0.3.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/loupe/releases/download/v0.3.0/loupe-v0.3.0-macos-aarch64.tar.gz"
      sha256 "0e9d19676ebe534abf3d21884f0af5e5303748235c912089705fbc1f6b56e743"
    else
      url "https://github.com/georgemandis/loupe/releases/download/v0.3.0/loupe-v0.3.0-macos-x86_64.tar.gz"
      sha256 "c22474e68a6d72fc5f53148d448407caad51bb0ea561d55f94f167c026016d13"
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
