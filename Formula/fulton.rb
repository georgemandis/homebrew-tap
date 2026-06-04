class Fulton < Formula
  desc "Cross-platform global keyboard shortcut daemon and C ABI library written in Zig"
  homepage "https://github.com/georgemandis/fulton"
  version "0.3.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/fulton/releases/download/v0.3.1/fulton-v0.3.1-macos-aarch64.tar.gz"
      sha256 "dce0e11793bcfa0b7ea7c89ea372566b9e83e0694e71994e73ac6a49b97de2ee"
    else
      url "https://github.com/georgemandis/fulton/releases/download/v0.3.1/fulton-v0.3.1-macos-x86_64.tar.gz"
      sha256 "ebf3a7e70e8900fa381dfb58845d3ac7eeb5f7f75fce00ec18c40feb7e08422d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/fulton/releases/download/v0.3.1/fulton-v0.3.1-linux-aarch64.tar.gz"
      sha256 "d066f870d654c2c4de2019a60d54bbd20c41111eda57aed68b83e94052efae8b"
    else
      url "https://github.com/georgemandis/fulton/releases/download/v0.3.1/fulton-v0.3.1-linux-x86_64.tar.gz"
      sha256 "6291ad5bb25c96632098abac3cf1bb9cf160a43a297c149ea5fd54ad2cd80450"
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
