class Copycat < Formula
  desc "Cross-platform clipboard CLI and C ABI library written in Zig"
  homepage "https://github.com/georgemandis/copycat"
  version "0.4.3"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/copycat/releases/download/v0.4.3/copycat-v0.4.3-macos-aarch64.tar.gz"
      sha256 "05353b4bab5c452a7d38d4a13f9db837a117b2a152cbc49523b91ae1b107db47"
    else
      url "https://github.com/georgemandis/copycat/releases/download/v0.4.3/copycat-v0.4.3-macos-x86_64.tar.gz"
      sha256 "4dee25060d528699af6370f9160c92068fbbd968266deeb7c89d0980e3d8d614"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/copycat/releases/download/v0.4.3/copycat-v0.4.3-linux-aarch64.tar.gz"
      sha256 "c2a3f897ebc0358581bb069240ab8277a371da4763276f7536229e8db49af9af"
    else
      url "https://github.com/georgemandis/copycat/releases/download/v0.4.3/copycat-v0.4.3-linux-x86_64.tar.gz"
      sha256 "8c2ccddc62281f0b3ecc5f4a4692372dde4802fd89337eb7e915519075245a8d"
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
