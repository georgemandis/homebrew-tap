class Lingua < Formula
  desc "Natural language processing CLI powered by native macOS APIs"
  homepage "https://github.com/georgemandis/lingua"
  version "0.1.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/lingua/releases/download/v0.1.0/lingua-v0.1.0-macos-aarch64.tar.gz"
      sha256 "652b28087e92b57e780b8ec324583f62dd0102c94f0089cc38f8bed5b253b964"
    else
      url "https://github.com/georgemandis/lingua/releases/download/v0.1.0/lingua-v0.1.0-macos-x86_64.tar.gz"
      sha256 "9e6a9b595fe06e9e003d21b6193fd32137c6f7c538fea6e5f0cf2359754b204c"
    end
  end

  def install
    bin.install "lingua"
  end

  test do
    assert_match "Usage: lingua", shell_output("#{bin}/lingua --help")
  end
end
