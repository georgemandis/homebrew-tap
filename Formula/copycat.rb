class Copycat < Formula
  desc "Cross-platform clipboard CLI and C ABI library written in Zig"
  homepage "https://github.com/georgemandis/copycat"
  version "0.3.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/copycat/releases/download/v0.3.1/copycat-v0.3.1-macos-aarch64.tar.gz"
      sha256 "2d66977a36d3e9d27063506ab1eff0b31c78c2c358eb3dae098a82c6a0b42b21"
    else
      url "https://github.com/georgemandis/copycat/releases/download/v0.3.1/copycat-v0.3.1-macos-x86_64.tar.gz"
      sha256 "b6b047f580d7145f7a1c36cb943fb82252ab6319ab7d0cfa3131932a35d54f29"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/copycat/releases/download/v0.3.1/copycat-v0.3.1-linux-aarch64.tar.gz"
      sha256 "5c02c5889a27db9a9b43908db168ebdd58489053af89aa833745cc409df4e70d"
    else
      url "https://github.com/georgemandis/copycat/releases/download/v0.3.1/copycat-v0.3.1-linux-x86_64.tar.gz"
      sha256 "d7f1c16acc1e41b08ef4de697a42d5b6804091f503960aa37c6c027a6ef82bc3"
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
