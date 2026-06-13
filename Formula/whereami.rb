class Whereami < Formula
  desc "Get your current location from the command-line using native OS APIs"
  homepage "https://github.com/georgemandis/whereami"
  version "0.3.3"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/whereami/releases/download/v0.3.3/whereami-v0.3.3-macos-aarch64.tar.gz"
      sha256 "3c3f918d6abf2d9f150bd22e4be4e149c331b0864515e5ee036f3394d73c5641"
    else
      url "https://github.com/georgemandis/whereami/releases/download/v0.3.3/whereami-v0.3.3-macos-x86_64.tar.gz"
      sha256 "16962247c4c9069f14ebcd7f14b34af035c0b6a7851a4b464992fc162beb980b"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/whereami/releases/download/v0.3.3/whereami-v0.3.3-linux-aarch64.tar.gz"
      sha256 "7784d13cd661da860639991af39afcbc414eab412cf69b033dd2eb91207ed69e"
    else
      url "https://github.com/georgemandis/whereami/releases/download/v0.3.3/whereami-v0.3.3-linux-x86_64.tar.gz"
      sha256 "adfc0ad6d263916d04d1431b72364280735e7d4e74108041035612cc7d375072"
    end
  end

  def install
    if OS.mac?
      prefix.install "whereami.app"
      bin.install_symlink prefix/"whereami.app/Contents/MacOS/whereami" => "whereami"
    else
      bin.install "whereami"
    end

    generate_completions_from_executable(bin/"whereami", "completions")
  end

  test do
    assert_match "Usage: whereami", shell_output("#{bin}/whereami --help")
  end
end
