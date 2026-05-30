class Copycat < Formula
  desc "Cross-platform clipboard CLI and C ABI library written in Zig"
  homepage "https://github.com/georgemandis/copycat"
  version "0.4.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/copycat/releases/download/v0.4.1/copycat-v0.4.1-macos-aarch64.tar.gz"
      sha256 "754c2d19fc1bbeb50deb082c52cc563b61a8a7220caa6736d076eee07ac23363"
    else
      url "https://github.com/georgemandis/copycat/releases/download/v0.4.1/copycat-v0.4.1-macos-x86_64.tar.gz"
      sha256 "405ce619d7ead24e9e1d780117884c165839b1dd620299338ec63d78a26ebced"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/copycat/releases/download/v0.4.1/copycat-v0.4.1-linux-aarch64.tar.gz"
      sha256 "59b7994ba81510864b667027fc11106b7af21a847d924bdba7ebb255325b08d9"
    else
      url "https://github.com/georgemandis/copycat/releases/download/v0.4.1/copycat-v0.4.1-linux-x86_64.tar.gz"
      sha256 "8bb88009cf480f6b012e8528abaad183bb8fc9fbb8db1de64ed91cd571753e30"
    end
  end

  def install
    bin.install "copycat"

    generate_completions_from_executable(bin/"copycat", "completions")
  end

  test do
    assert_match "Usage: copycat", shell_output("#{bin}/copycat --help")
  end
end
