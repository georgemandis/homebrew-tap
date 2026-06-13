class Cacophony < Formula
  desc "Sound classification from the command line using native macOS SoundAnalysis"
  homepage "https://github.com/georgemandis/cacophony"
  version "0.1.1"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/cacophony/releases/download/v0.1.1/cacophony-v0.1.1-macos-aarch64.tar.gz"
      sha256 "8abe7cfa11e542cb2a8fd1d7df2dc79ed20629b95345203efb68ab57c7d82f24"
    else
      url "https://github.com/georgemandis/cacophony/releases/download/v0.1.1/cacophony-v0.1.1-macos-x86_64.tar.gz"
      sha256 "4be9533463b57eb5e03ad0cd754fd5f7011580b3aec78e460d050fa0fd190c84"
    end
  end

  def install
    bin.install "cacophony"

    generate_completions_from_executable(bin/"cacophony", "completions")
  end

  test do
    assert_match "Usage: cacophony", shell_output("#{bin}/cacophony --help")
  end
end
