class Copycat < Formula
  desc "Cross-platform clipboard CLI and C ABI library written in Zig"
  homepage "https://github.com/georgemandis/copycat"
  version "0.4.5"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/copycat/releases/download/v0.4.5/copycat-v0.4.5-macos-aarch64.tar.gz"
      sha256 "f1bfac8d4a21e5fe5549fb0adf54b425a969665e16eed327c181fd404052410c"
    else
      url "https://github.com/georgemandis/copycat/releases/download/v0.4.5/copycat-v0.4.5-macos-x86_64.tar.gz"
      sha256 "ef1e450558e92ef73afcc279a4613759e8b269ba4538d93d49cd06c33feb5426"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/copycat/releases/download/v0.4.5/copycat-v0.4.5-linux-aarch64.tar.gz"
      sha256 "7e71bdd8ab7072a59e8b17be551ba9674fc550d207e80396e2344864f4b1f4b3"
    else
      url "https://github.com/georgemandis/copycat/releases/download/v0.4.5/copycat-v0.4.5-linux-x86_64.tar.gz"
      sha256 "135d70aeae023b418c17e20b1c7bc4f2df86a642d475195fa5114df9f9d3d3c5"
    end
  end

  def install
    bin.install "copycat"

    generate_completions_from_executable(bin/"copycat", "completions")
  end

  test do
    assert_match "Usage: copycat", shell_output("#{bin}/copycat --help")
  end
end
