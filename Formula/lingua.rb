class Lingua < Formula
  desc "Natural language processing CLI powered by native macOS APIs"
  homepage "https://github.com/georgemandis/lingua"
  version "0.6.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/lingua/releases/download/v0.6.0/lingua-v0.6.0-macos-aarch64.tar.gz"
      sha256 "c154a5eaff73c47d06f6eca291a0c937e8924b599e939e4d6a7668b32b394e2c"
    else
      url "https://github.com/georgemandis/lingua/releases/download/v0.6.0/lingua-v0.6.0-macos-x86_64.tar.gz"
      sha256 "163d93c1159ae8c43f6096cec645ba3fb16fa990e0caae210bb2e38d0e7e1871"
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
