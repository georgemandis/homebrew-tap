class Whereami < Formula
  desc "Get your current location from the command line using native OS APIs"
  homepage "https://github.com/georgemandis/whereami"
  version "0.1.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/whereami/releases/download/v0.1.0/whereami-v0.1.0-macos-aarch64.tar.gz"
      sha256 "1b926ee18b72c65a2049a385bc7507ea39ddd2c3811afe237142a6b425bf72ed"
    else
      url "https://github.com/georgemandis/whereami/releases/download/v0.1.0/whereami-v0.1.0-macos-x86_64.tar.gz"
      sha256 "4ea4992acbbf36d47afef6465243a508baab138e3eb28cbb3ca0eedf1c2f9cb2"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/whereami/releases/download/v0.1.0/whereami-v0.1.0-linux-aarch64.tar.gz"
      sha256 "648878dc048f227119bfc24f8b81911ef52ebc145d37bbefeafd218173c850f5"
    else
      url "https://github.com/georgemandis/whereami/releases/download/v0.1.0/whereami-v0.1.0-linux-x86_64.tar.gz"
      sha256 "8f6b9deceb46b5e08cccf2a684928517f16cfccf6be11fbafa01d6e1ec86eda8"
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
