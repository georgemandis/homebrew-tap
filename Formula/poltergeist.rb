class Poltergeist < Formula
  desc "Cross-platform accessibility CLI for inspecting UI elements and managing windows"
  homepage "https://github.com/georgemandis/poltergeist"
  version "0.2.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/poltergeist/releases/download/v0.2.0/poltergeist-v0.2.0-macos-aarch64.tar.gz"
      sha256 "a03d6d6205c17d1a2e186ab8351dab7e87b1f8ff55c6585d18b85f34cacb78a8"
    else
      url "https://github.com/georgemandis/poltergeist/releases/download/v0.2.0/poltergeist-v0.2.0-macos-x86_64.tar.gz"
      sha256 "918a44c8b8d7e2c84b2f9fd2385122a9e110879d730140b264d37f6fa8ace768"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/poltergeist/releases/download/v0.2.0/poltergeist-v0.2.0-linux-aarch64.tar.gz"
      sha256 "4ac6450622e7daa1bb5edbe351ec1780eb0b52e2bfe6401b6cec34363a90e506"
    else
      url "https://github.com/georgemandis/poltergeist/releases/download/v0.2.0/poltergeist-v0.2.0-linux-x86_64.tar.gz"
      sha256 "93925537b39b59408e7a89d6914b85ca223e587750bd5374f3924e0a02bfeb93"
    end

    depends_on "at-spi2-core"
    depends_on "glib"
    depends_on "libx11"
  end

  def install
    bin.install "poltergeist"
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
