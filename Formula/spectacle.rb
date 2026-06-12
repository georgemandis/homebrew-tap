class Spectacle < Formula
  desc "Screen and system audio capture CLI using native OS APIs"
  homepage "https://github.com/georgemandis/spectacle"
  version "0.2.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/spectacle/releases/download/v0.2.0/spectacle-v0.2.0-macos-aarch64.tar.gz"
      sha256 "a6ba0474c799331a749fff97003119c8d5b50a497e693ab61b5396ae97439066"
    else
      url "https://github.com/georgemandis/spectacle/releases/download/v0.2.0/spectacle-v0.2.0-macos-x86_64.tar.gz"
      sha256 "18c928e6b82234b12fcb6ff2670e4930c05fa672bc2b4c0cf48ec32b434c0053"
    end
  end

  def install
    bin.install "spectacle"

    generate_completions_from_executable(bin/"spectacle", "completions")
  end

  test do
    assert_match "spectacle", shell_output("#{bin}/spectacle --version")
  end
end
