class Holdline < Formula
  desc "Freeze merges across your GitHub org from the terminal"
  homepage "https://github.com/lesssoftware/releases"
  # tag_prefix: holdline-v
  version "0.1.0"
  license "MIT"

  # Apple Silicon only on macOS (no Intel build shipped).
  depends_on arch: :arm64 if OS.mac?

  on_macos do
    url "https://github.com/lesssoftware/releases/releases/download/holdline-v0.1.0/holdline-v0.1.0-macos-aarch64.tar.gz"
    sha256 "d6a2920c22e4ee9e1d55325a60a5eca89fb48c5ffeb9005e82632088fc8ae9de"
  end

  on_linux do
    url "https://github.com/lesssoftware/releases/releases/download/holdline-v0.1.0/holdline-v0.1.0-linux-x86_64.tar.gz"
    sha256 "85ee3aa16a8cdefd5d87fc931fcdffa5b492c6d8915c1f1284778fd9ba2e3d2c"
  end

  def install
    bin.install "holdline"

    generate_completions_from_executable(bin/"holdline", "completions")
  end

  test do
    assert_match "holdline v", shell_output("#{bin}/holdline --version")
  end
end
