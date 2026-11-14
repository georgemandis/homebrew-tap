class Whereami < Formula
  desc "Get your current location from the command-line using native OS APIs"
  homepage "https://github.com/georgemandis/whereami"
  version "0.4.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/whereami/releases/download/v0.4.0/whereami-v0.4.0-macos-aarch64.tar.gz"
      sha256 "f7e05a18ee82f021692575024da9690cbbd525e9f64ae06f171b87faed5343b7"
    else
      url "https://github.com/georgemandis/whereami/releases/download/v0.4.0/whereami-v0.4.0-macos-x86_64.tar.gz"
      sha256 "3f5255ff8421798f34a7bbe9b3c487e74161d372867463a113bad4751e1dcbf1"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/whereami/releases/download/v0.4.0/whereami-v0.4.0-linux-aarch64.tar.gz"
      sha256 "9c237cd510a0ab4852694ab706703f7f9864a2a537aa8c50858c45bba437b84c"
    else
      url "https://github.com/georgemandis/whereami/releases/download/v0.4.0/whereami-v0.4.0-linux-x86_64.tar.gz"
      sha256 "9d4f3f0e92c3ae049f45d28a91a7b4b8b27f4ff4a81559cb3bb247a568c04563"
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
