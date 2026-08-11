class Lingua < Formula
  desc "Natural language processing CLI powered by native macOS APIs"
  homepage "https://github.com/georgemandis/lingua"
  version "0.6.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/lingua/releases/download/v0.6.0/lingua-v0.6.0-macos-aarch64.tar.gz"
      sha256 "0b7ba33ea250ff149f88e6affcb7b9acdace25c6dbf2652a4129f200e4f4b3db"
    else
      url "https://github.com/georgemandis/lingua/releases/download/v0.6.0/lingua-v0.6.0-macos-x86_64.tar.gz"
      sha256 "cf2429ccd465b767d6e45dc2e79fde5c1cddfb40c2abc8bc394dc3462b1b183e"
    end
  end

  def install
    bin.install "lingua"

    generate_completions_from_executable(bin/"lingua", "completions")
  end

  test do
    assert_match "Usage: lingua", shell_output("#{bin}/lingua --help")
  end
end
