class Stenographer < Formula
  desc "Speech-to-text from the command line using native macOS Speech Recognition"
  homepage "https://github.com/georgemandis/stenographer"
  version "0.1.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/stenographer/releases/download/v0.1.0/stenographer-v0.1.0-macos-aarch64.tar.gz"
      sha256 "b4db83eb6db5c37a91657f95aafd71dc79375aa2dd5008101a1d3da9ba147b8b"
    else
      url "https://github.com/georgemandis/stenographer/releases/download/v0.1.0/stenographer-v0.1.0-macos-x86_64.tar.gz"
      sha256 "623a0cf1591157a1343ead2a242f6c1a8eeddf85392d370d52429b137f54fae5"
    end
  end

  def install
    bin.install "stenographer"
  end

  test do
    assert_match "Usage: stenographer", shell_output("#{bin}/stenographer --help")
  end
end
