class Copycat < Formula
  desc "Cross-platform clipboard CLI and C ABI library written in Zig"
  homepage "https://github.com/georgemandis/copycat"
  version "0.4.4"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/copycat/releases/download/v0.4.4/copycat-v0.4.4-macos-aarch64.tar.gz"
      sha256 "d9031f8bd5b5b09a670508e1506a592cf8f2a1abfc53cfef9d17a77f53cca368"
    else
      url "https://github.com/georgemandis/copycat/releases/download/v0.4.4/copycat-v0.4.4-macos-x86_64.tar.gz"
      sha256 "eb32f71ff573ea05b8caa8a54c74e904d2d4ba5fdb8d77fb9fbcc2483e24fdcf"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/copycat/releases/download/v0.4.4/copycat-v0.4.4-linux-aarch64.tar.gz"
      sha256 "ebf54e612031fdc0885d09e5b52357afbcc5f7b09c6149eef7b389d77cdc656c"
    else
      url "https://github.com/georgemandis/copycat/releases/download/v0.4.4/copycat-v0.4.4-linux-x86_64.tar.gz"
      sha256 "a999fb78fb454951eedfa104d5faaae50c36702deb559a7b0a7d2ae841b6cbc6"
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
