class Cacophony < Formula
  desc "Sound classification from the command line using native macOS SoundAnalysis"
  homepage "https://github.com/georgemandis/cacophony"
  version "0.1.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/cacophony/releases/download/v0.1.0/cacophony-v0.1.0-macos-aarch64.tar.gz"
      sha256 "cb258f08bc7066152760a2999127c0d46c88ee12a472cd152cdd6ef014fd66ec"
    else
      url "https://github.com/georgemandis/cacophony/releases/download/v0.1.0/cacophony-v0.1.0-macos-x86_64.tar.gz"
      sha256 "5530a4ac43406ae32bc165f7a11a42833e85b77afee5689eb28319f15ccf92e4"
    end
  end

  def install
    bin.install "cacophony"
  end

  test do
    assert_match "Usage: cacophony", shell_output("#{bin}/cacophony --help")
  end
end
