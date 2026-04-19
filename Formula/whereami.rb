class Whereami < Formula
  desc "Get your current location from the command line using native OS APIs"
  homepage "https://github.com/georgemandis/whereami"
  version "0.2.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/whereami/releases/download/v0.2.1/whereami-v0.2.1-macos-aarch64.tar.gz"
      sha256 "459c0621bb05f793cb645248e9ddc422b24154d444b6b9814cf82a5602fb0b32"
    else
      url "https://github.com/georgemandis/whereami/releases/download/v0.2.1/whereami-v0.2.1-macos-x86_64.tar.gz"
      sha256 "739c6aff6f5593a5b53ce01cbf9b7dfdb2eed40f6e3540770367c03b6394d089"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/whereami/releases/download/v0.2.1/whereami-v0.2.1-linux-aarch64.tar.gz"
      sha256 "62720b5f620722f5b79823ec2aeeb06b03093b142b338f4e043f57293fd85f8f"
    else
      url "https://github.com/georgemandis/whereami/releases/download/v0.2.1/whereami-v0.2.1-linux-x86_64.tar.gz"
      sha256 "c92f2e25a0833d75653fad8679056af0d7521522beef476efa10b1054fe45321"
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
