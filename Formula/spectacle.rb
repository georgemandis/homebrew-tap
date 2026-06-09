class Spectacle < Formula
  desc "Screen and system audio capture CLI using native OS APIs"
  homepage "https://github.com/georgemandis/spectacle"
  version "0.1.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/spectacle/releases/download/v0.1.0/spectacle-v0.1.0-macos-aarch64.tar.gz"
      sha256 "7deba1e0aec671f8bad373a1584ea7f250c37ffb8c029126261de58c143f32f0"
    else
      url "https://github.com/georgemandis/spectacle/releases/download/v0.1.0/spectacle-v0.1.0-macos-x86_64.tar.gz"
      sha256 "37f5117378b053a305cb8914fd165985f378c895503f4ce5d211a59d7c457168"
    end
  end

  def install
    bin.install "spectacle"
  end

  test do
    assert_match "spectacle", shell_output("#{bin}/spectacle --version")
  end
end
