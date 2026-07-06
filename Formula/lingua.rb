class Lingua < Formula
  desc "Natural language processing CLI powered by native macOS APIs"
  homepage "https://github.com/georgemandis/lingua"
  version "0.3.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/lingua/releases/download/v0.3.0/lingua-v0.3.0-macos-aarch64.tar.gz"
      sha256 "d6f186a478729f325e56724f17361b58495246fab8cac782b6e2124a6022b9c6"
    else
      url "https://github.com/georgemandis/lingua/releases/download/v0.3.0/lingua-v0.3.0-macos-x86_64.tar.gz"
      sha256 "bd5d9297acdb3d33ee3e797d68226a8ebcbda15fc8248cc582997c93a5405342"
    end
  end

  def install
    bin.install "lingua"

    generate_completions_from_executable(bin/"lingua", "completions")
  end

  test do
    assert_match "Usage: lingua", shell_output("#{bin}/lingua --help")
  end
end
