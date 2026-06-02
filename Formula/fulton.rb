class Fulton < Formula
  desc "Cross-platform global keyboard shortcut daemon and C ABI library written in Zig"
  homepage "https://github.com/georgemandis/fulton"
  version "0.2.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/fulton/releases/download/v0.2.0/fulton-v0.2.0-macos-aarch64.tar.gz"
      sha256 "365f2d5eee2dcc49b38ecb859640c541de7546259eb17dc711fbd31b4e4cb641"
    else
      url "https://github.com/georgemandis/fulton/releases/download/v0.2.0/fulton-v0.2.0-macos-x86_64.tar.gz"
      sha256 "3af4221a19f81c76091ac0fa157172a23ac8481c1a049de51f5dde01c8770bb2"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/fulton/releases/download/v0.2.0/fulton-v0.2.0-linux-aarch64.tar.gz"
      sha256 "98f0e661ffe38443506289d54f26d459359e11e6e5490b6f83d32cd2f3ff8098"
    else
      url "https://github.com/georgemandis/fulton/releases/download/v0.2.0/fulton-v0.2.0-linux-x86_64.tar.gz"
      sha256 "4b4334e529632c7f7cda0a604824515a92509fc64e504b2e894e55ac181563c1"
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
