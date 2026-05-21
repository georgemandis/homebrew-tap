class Whereami < Formula
  desc "Get your current location from the command-line using native OS APIs"
  homepage "https://github.com/georgemandis/whereami"
  version "0.3.2"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/whereami/releases/download/v0.3.2/whereami-v0.3.2-macos-aarch64.tar.gz"
      sha256 "936b6341b9074828c1d07efa5a5ee970c391bd5b22710b330f6260ec0bc07634"
    else
      url "https://github.com/georgemandis/whereami/releases/download/v0.3.2/whereami-v0.3.2-macos-x86_64.tar.gz"
      sha256 "3720a1b2508cb41db509c5171b5d3418ba8d80214b40bf10e5ba769ee1b5caa2"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/whereami/releases/download/v0.3.2/whereami-v0.3.2-linux-aarch64.tar.gz"
      sha256 "de1d3bce2b841403697aa27f418194367c96de3dfab75b104f0e5f30bad52e11"
    else
      url "https://github.com/georgemandis/whereami/releases/download/v0.3.2/whereami-v0.3.2-linux-x86_64.tar.gz"
      sha256 "ef37b2c146489fb8070151f4b8549f0a8db3880faa262e42d90a5b1f2659b800"
    end
  end

  def install
    if OS.mac?
      prefix.install "whereami.app"
      bin.install_symlink prefix/"whereami.app/Contents/MacOS/whereami" => "whereami"
    else
      bin.install "whereami"
    end
  end

  test do
    assert_match "Usage: whereami", shell_output("#{bin}/whereami --help")
  end
end
