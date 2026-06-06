class Tezcatl < Formula
  desc "Lightweight CLI for rendering web pages using native macOS WebKit"
  homepage "https://github.com/georgemandis/tezcatl"
  version "0.2.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/tezcatl/releases/download/v0.2.0/tezcatl-v0.2.0-macos-aarch64.tar.gz"
      sha256 "f7d439424a67db8a8f74bef57b6b77961cd35f7bb6b0f7249661f2addd18df8a"
    else
      url "https://github.com/georgemandis/tezcatl/releases/download/v0.2.0/tezcatl-v0.2.0-macos-x86_64.tar.gz"
      sha256 "3a4a71262adde0325767de68b5e884ff8d78ca2ba6943095b86e3b1a24c403ce"
    end
  end

  def install
    bin.install "tezcatl"
    bash_completion.install "completions/tezcatl.bash" => "tezcatl"
    zsh_completion.install "completions/tezcatl.zsh" => "_tezcatl"
    fish_completion.install "completions/tezcatl.fish"
  end

  test do
    assert_match "Usage: tezcatl", shell_output("#{bin}/tezcatl --help")
  end
end
