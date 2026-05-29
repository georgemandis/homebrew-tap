class Tezcatl < Formula
  desc "Lightweight CLI for rendering web pages using native macOS WebKit"
  homepage "https://github.com/georgemandis/tezcatl"
  version "0.1.1"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/tezcatl/releases/download/v0.1.1/tezcatl-v0.1.1-macos-aarch64.tar.gz"
      sha256 "c5662988bf0b920a5fbb546179841d9bd992d59e9bdc845f30ebc335a1910fcc"
    else
      url "https://github.com/georgemandis/tezcatl/releases/download/v0.1.1/tezcatl-v0.1.1-macos-x86_64.tar.gz"
      sha256 "34296fe6c921788b776584119bdab8b21861e7df517e67f5f185c7f7aff1242e"
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
