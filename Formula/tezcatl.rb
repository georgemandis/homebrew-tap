class Tezcatl < Formula
  desc "Lightweight CLI for rendering web pages using native macOS WebKit"
  homepage "https://github.com/georgemandis/tezcatl"
  version "0.3.0"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/tezcatl/releases/download/v0.3.0/tezcatl-v0.3.0-macos-aarch64.tar.gz"
      sha256 "193d184d3903ebc7483750e4be13b9dd0df3145e89831984145c9c87c5e0541a"
    else
      url "https://github.com/georgemandis/tezcatl/releases/download/v0.3.0/tezcatl-v0.3.0-macos-x86_64.tar.gz"
      sha256 "193d184d3903ebc7483750e4be13b9dd0df3145e89831984145c9c87c5e0541a"
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
