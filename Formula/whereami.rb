class Whereami < Formula
  desc "Get your current location from the command-line using native OS APIs"
  homepage "https://github.com/georgemandis/whereami"
  version "0.3.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/whereami/releases/download/v0.3.0/whereami-v0.3.0-macos-aarch64.tar.gz"
      sha256 "6286b70497d69d64e196e1b1e3c630c343ad409265448cf68868c9ac15516335"
    else
      url "https://github.com/georgemandis/whereami/releases/download/v0.3.0/whereami-v0.3.0-macos-x86_64.tar.gz"
      sha256 "481fe06a72fef3e00b77d29c9ed242bea5111327df2e3392ac43dea220d5b9e6"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/whereami/releases/download/v0.3.0/whereami-v0.3.0-linux-aarch64.tar.gz"
      sha256 "761b41a091dc4a48f5358317555adebf19a035971d60390fdc211111a266e300"
    else
      url "https://github.com/georgemandis/whereami/releases/download/v0.3.0/whereami-v0.3.0-linux-x86_64.tar.gz"
      sha256 "1e8d1fad1173dfade89faf82b5d2a2e5677da4765c5d9e1d3c9aa75a643840ad"
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
