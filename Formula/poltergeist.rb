class Poltergeist < Formula
  desc "Cross-platform accessibility CLI for inspecting UI elements and managing windows"
  homepage "https://github.com/georgemandis/poltergeist"
  version "0.2.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/poltergeist/releases/download/v0.2.1/poltergeist-v0.2.1-macos-aarch64.tar.gz"
      sha256 "0027a49c25697ddb5d368aafff06127d2cf35b72cf5e994a24dbe197f49efb2c"
    else
      url "https://github.com/georgemandis/poltergeist/releases/download/v0.2.1/poltergeist-v0.2.1-macos-x86_64.tar.gz"
      sha256 "220f56a0fee19402ef81f295ea560685fb6122571d8eea989927e979318b2f47"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/poltergeist/releases/download/v0.2.1/poltergeist-v0.2.1-linux-aarch64.tar.gz"
      sha256 "22fc41329e0e3e11b29ab9fc5ced3b4312505fa8dcd487bf8e6b53e03f4c0abc"
    else
      url "https://github.com/georgemandis/poltergeist/releases/download/v0.2.1/poltergeist-v0.2.1-linux-x86_64.tar.gz"
      sha256 "eb719730d68852ca49a221348814d40e800bcd87f4ad993a1d39be4560eb6207"
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
