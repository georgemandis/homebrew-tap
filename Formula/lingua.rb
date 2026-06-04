class Lingua < Formula
  desc "Natural language processing CLI powered by native macOS APIs"
  homepage "https://github.com/georgemandis/lingua"
  version "0.2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/lingua/releases/download/v0.2.0/lingua-v0.2.0-macos-aarch64.tar.gz"
      sha256 "99f73b0a7956b054316a52596b6735a68165fa0f06dffa2aa0051cd5117e9656"
    else
      url "https://github.com/georgemandis/lingua/releases/download/v0.2.0/lingua-v0.2.0-macos-x86_64.tar.gz"
      sha256 "4107adf1f2679346a992e5cff7892a296d5cf897b3cd96d78c1eb249358a5072"
    end
  end

  def install
    bin.install "lingua"
  end

  test do
    assert_match "Usage: lingua", shell_output("#{bin}/lingua --help")
  end
end
