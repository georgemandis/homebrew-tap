class Fulton < Formula
  desc "Cross-platform global keyboard shortcut daemon and C ABI library written in Zig"
  homepage "https://github.com/georgemandis/fulton"
  version "0.3.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/fulton/releases/download/v0.3.0/fulton-v0.3.0-macos-aarch64.tar.gz"
      sha256 "6eeeb41d45050ec11e79c8b6fb14d5aada79f2f7eb2da33a5cdf845f314ad076"
    else
      url "https://github.com/georgemandis/fulton/releases/download/v0.3.0/fulton-v0.3.0-macos-x86_64.tar.gz"
      sha256 "17a6481d36a304f1dc4a818a948ac019c12187d0a14353c04fc7a8f2d7fe6d78"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/fulton/releases/download/v0.3.0/fulton-v0.3.0-linux-aarch64.tar.gz"
      sha256 "a939a160a9bcd1dedc28cca85e5e5cb1dfe3ae10cd3a432604bb4f52d851a071"
    else
      url "https://github.com/georgemandis/fulton/releases/download/v0.3.0/fulton-v0.3.0-linux-x86_64.tar.gz"
      sha256 "2d6fdddf52ee4fe4b4f931c00233905e5aed2819c618355659718a36e581227b"
    end
  end

  def install
    bin.install "fulton"
  end

  def caveats
    on_linux do
      <<~EOS
        On Wayland, fulton needs permission to read keyboard input devices.
        Add your user to the input group (recommended):

          sudo usermod -aG input $USER

        Then log out and back in for the change to take effect.
        Run `fulton --setup` for more options.
      EOS
    end
  end

  test do
    assert_match "Usage: fulton", shell_output("#{bin}/fulton --help")
  end
end
