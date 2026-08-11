class Poltergeist < Formula
  desc "Cross-platform accessibility CLI for inspecting UI elements and managing windows"
  homepage "https://github.com/georgemandis/poltergeist"
  version "0.1.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/poltergeist/releases/download/v0.1.1/poltergeist-v0.1.1-macos-aarch64.tar.gz"
      sha256 "87c475fd3909ceea630a98bb9f700617939474d0f9544d7debebea57a7b95169"
    else
      url "https://github.com/georgemandis/poltergeist/releases/download/v0.1.1/poltergeist-v0.1.1-macos-x86_64.tar.gz"
      sha256 "ec416f3e2db85980a5f4c6ae33761e38dba3ccb95463bad63fc7ed9da001bf87"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/poltergeist/releases/download/v0.1.1/poltergeist-v0.1.1-linux-aarch64.tar.gz"
      sha256 "53786642b25ba25b10d97272cf330b6ad3c44206f2976eae008fc87064620cb2"
    else
      url "https://github.com/georgemandis/poltergeist/releases/download/v0.1.1/poltergeist-v0.1.1-linux-x86_64.tar.gz"
      sha256 "25df3efb8ce3087f7284ac5d107d5dc161de7a2db668daa2da288ca02f9908f6"
    end

    depends_on "at-spi2-core"
    depends_on "glib"
    depends_on "libx11"
  end

  def install
    bin.install "poltergeist"

    generate_completions_from_executable(bin/"poltergeist", "completions")
  end

  def caveats
    s = ""
    on_macos do
      s = <<~EOS
        Poltergeist requires Accessibility permission.
        Grant access in System Settings > Privacy & Security > Accessibility.
      EOS
    end
    on_linux do
      s = <<~EOS
        Poltergeist requires GNOME accessibility to be enabled:
          gsettings set org.gnome.desktop.interface toolkit-accessibility true
        Then restart any running applications.
      EOS
    end
    s
  end

  test do
    assert_match "poltergeist", shell_output("#{bin}/poltergeist --version")
  end
end
