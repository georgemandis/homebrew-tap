class Cacophony < Formula
  desc "Sound classification from the command line using native macOS SoundAnalysis"
  homepage "https://github.com/georgemandis/cacophony"
  version "0.1.1"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/cacophony/releases/download/v0.1.1/cacophony-v0.1.1-macos-aarch64.tar.gz"
      sha256 "eb25d85d540ebe43830a728f35120fb2097c213fdeebc4b28faab6f323133c79"
    else
      url "https://github.com/georgemandis/cacophony/releases/download/v0.1.1/cacophony-v0.1.1-macos-x86_64.tar.gz"
      sha256 "f8ae71835987bd83258daed009c183c2f1e02cfb9a3654c802d21a352703bcfe"
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
