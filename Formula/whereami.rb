class Whereami < Formula
  desc "Get your current location from the command line using native OS APIs"
  homepage "https://github.com/georgemandis/whereami"
  version "0.2.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/whereami/releases/download/v0.2.0/whereami-v0.2.0-macos-aarch64.tar.gz"
      sha256 "2002a74da29b345f0b6b5b5021d5c9979b177ad99df80c7451fed3f8a150d8a4"
    else
      url "https://github.com/georgemandis/whereami/releases/download/v0.2.0/whereami-v0.2.0-macos-x86_64.tar.gz"
      sha256 "306e632bc124d47b20a69c31ed8aa818bcd150c7f3e07ce8628a94261cf88acb"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/whereami/releases/download/v0.2.0/whereami-v0.2.0-linux-aarch64.tar.gz"
      sha256 "53000e8bfd5579ed574a561c5e0c4bda62d9944d9d3e96b8f5ca39f3c1a3047d"
    else
      url "https://github.com/georgemandis/whereami/releases/download/v0.2.0/whereami-v0.2.0-linux-x86_64.tar.gz"
      sha256 "31873ef4e0ef3f7ef90463ea0b1ccebd751bd557ef768b8f2fb10f26ba42500f"
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
