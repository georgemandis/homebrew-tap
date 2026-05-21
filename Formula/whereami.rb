class Whereami < Formula
  desc "Get your current location from the command-line using native OS APIs"
  homepage "https://github.com/georgemandis/whereami"
  version "0.3.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/whereami/releases/download/v0.3.1/whereami-v0.3.1-macos-aarch64.tar.gz"
      sha256 "3de4502b2de763379a925214901bc6678801892d7dac8bec2e8e1074843877eb"
    else
      url "https://github.com/georgemandis/whereami/releases/download/v0.3.1/whereami-v0.3.1-macos-x86_64.tar.gz"
      sha256 "953c50f30691e48592fd067e2ccb02b016d1dae290ef2f4c9ddf1f606ad9e673"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/whereami/releases/download/v0.3.1/whereami-v0.3.1-linux-aarch64.tar.gz"
      sha256 "d48add51e3c7c40f5fbba5dcb273acc97c7c54c8ac11f0275e8974f8ea011741"
    else
      url "https://github.com/georgemandis/whereami/releases/download/v0.3.1/whereami-v0.3.1-linux-x86_64.tar.gz"
      sha256 "1a9a83e537734a39ec093b78cfda055d6a541a6bf24d039467a54174505cc781"
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
