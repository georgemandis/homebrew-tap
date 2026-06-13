class Fulton < Formula
  desc "Cross-platform global keyboard shortcut daemon and C ABI library written in Zig"
  homepage "https://github.com/georgemandis/fulton"
  version "0.3.2"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/fulton/releases/download/v0.3.2/fulton-v0.3.2-macos-aarch64.tar.gz"
      sha256 "033550cb1f6aeeba370c755bda3592c2dfa9f838bc810e2004e884ed309579af"
    else
      url "https://github.com/georgemandis/fulton/releases/download/v0.3.2/fulton-v0.3.2-macos-x86_64.tar.gz"
      sha256 "1c139295a2188ef06a9fdb00009265a0decf46c4cc7c25aa1b82e79775a3115d"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/fulton/releases/download/v0.3.2/fulton-v0.3.2-linux-aarch64.tar.gz"
      sha256 "ef47f2b222bfa34176e89b9ef0e88f8b91b47590d162b59050d7b09e6502324c"
    else
      url "https://github.com/georgemandis/fulton/releases/download/v0.3.2/fulton-v0.3.2-linux-x86_64.tar.gz"
      sha256 "c7ca824e5296c7a30485d9892411c80c84053fb4f98307a63769bf2d48afb71f"
    end
  end

  def install
    bin.install "fulton"

    generate_completions_from_executable(bin/"fulton", "completions")
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
