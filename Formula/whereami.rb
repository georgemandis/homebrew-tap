class Whereami < Formula
  desc "Get your current location from the command-line using native OS APIs"
  homepage "https://github.com/georgemandis/whereami"
  version "0.3.3"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/whereami/releases/download/v0.3.3/whereami-v0.3.3-macos-aarch64.tar.gz"
      sha256 "2a6bf11dc757e8745956922a1260bd62757ca5a8150cd2f81a209a46e38e45f3"
    else
      url "https://github.com/georgemandis/whereami/releases/download/v0.3.3/whereami-v0.3.3-macos-x86_64.tar.gz"
      sha256 "84c7060e24411ff639d9d66fbb052d933ec574dea0131f0840822897907e700b"
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
