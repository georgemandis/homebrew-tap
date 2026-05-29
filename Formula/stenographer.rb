class Stenographer < Formula
  desc "Speech-to-text from the command line using native macOS Speech Recognition"
  homepage "https://github.com/georgemandis/stenographer"
  version "0.2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/stenographer/releases/download/v0.2.0/stenographer-v0.2.0-macos-aarch64.tar.gz"
      sha256 "eff64487fccde6bfd1d823af74e50de7471d466b9a7f6265072e9ee97ab11ab9"
    else
      url "https://github.com/georgemandis/stenographer/releases/download/v0.2.0/stenographer-v0.2.0-macos-x86_64.tar.gz"
      sha256 "2a5cbd6f97c06332f455d9efb55df461ceb00c4c4269536c1c2d4f8e8be59457"
    end
  end

  def install
    bin.install "stenographer"
  end

  test do
    assert_match "Usage: stenographer", shell_output("#{bin}/stenographer --help")
  end
end
