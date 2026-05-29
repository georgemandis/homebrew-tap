class Cacophony < Formula
  desc "Sound classification from the command line using native macOS SoundAnalysis"
  homepage "https://github.com/georgemandis/cacophony"
  version "0.1.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/cacophony/releases/download/v0.1.0/cacophony-v0.1.0-macos-aarch64.tar.gz"
      sha256 "PLACEHOLDER"
    else
      url "https://github.com/georgemandis/cacophony/releases/download/v0.1.0/cacophony-v0.1.0-macos-x86_64.tar.gz"
      sha256 "PLACEHOLDER"
    end
  end

  def install
    bin.install "cacophony"
  end

  test do
    assert_match "Usage: cacophony", shell_output("#{bin}/cacophony --help")
  end
end
