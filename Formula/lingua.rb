class Lingua < Formula
  desc "Natural language processing CLI powered by native macOS APIs"
  homepage "https://github.com/georgemandis/lingua"
  version "0.2.1"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/lingua/releases/download/v0.2.1/lingua-v0.2.1-macos-aarch64.tar.gz"
      sha256 "3f4ddb9021d195a6794c4865914e86b3873e4aa03ca4008041be532538c11b7a"
    else
      url "https://github.com/georgemandis/lingua/releases/download/v0.2.1/lingua-v0.2.1-macos-x86_64.tar.gz"
      sha256 "bdd0c8455fe842d84dfe3ed3321f04098f7779e17cb6953fcd4cceb9b82c9054"
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
