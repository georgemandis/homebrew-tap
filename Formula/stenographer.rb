class Stenographer < Formula
  desc "Speech-to-text from the command line using native macOS Speech Recognition"
  homepage "https://github.com/georgemandis/stenographer"
  version "0.1.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/stenographer/releases/download/v0.1.0/stenographer-v0.1.0-macos-aarch64.tar.gz"
      sha256 "PLACEHOLDER"
    else
      url "https://github.com/georgemandis/stenographer/releases/download/v0.1.0/stenographer-v0.1.0-macos-x86_64.tar.gz"
      sha256 "PLACEHOLDER"
    end
  end

  def install
    bin.install "stenographer"
  end

  test do
    assert_match "Usage: stenographer", shell_output("#{bin}/stenographer --help")
  end
end
