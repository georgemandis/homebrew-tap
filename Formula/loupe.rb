class Loupe < Formula
  desc "Computer vision CLI for face detection, OCR, and barcode scanning"
  homepage "https://github.com/georgemandis/loupe"
  version "0.3.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/loupe/releases/download/v0.3.1/loupe-v0.3.1-macos-aarch64.tar.gz"
      sha256 "548f4971ad83d12bdd1605f916484b8f73b4712a8b3d027f2bd6a26c10c0cfa8"
    else
      url "https://github.com/georgemandis/loupe/releases/download/v0.3.1/loupe-v0.3.1-macos-x86_64.tar.gz"
      sha256 "1993f0cee118940102cb29aef9d0bdf64c723f797e31d87436194bba57a59770"
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
