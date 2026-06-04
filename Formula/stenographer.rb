class Stenographer < Formula
  desc "Speech-to-text from the command line using native macOS Speech Recognition"
  homepage "https://github.com/georgemandis/stenographer"
  version "0.2.2"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/stenographer/releases/download/v0.2.2/stenographer-v0.2.2-macos-aarch64.tar.gz"
      sha256 "35fa8564b13e0f272017355ada61f46fc2cfaffc9217a47ee0fb0e2f7792a13f"
    else
      url "https://github.com/georgemandis/stenographer/releases/download/v0.2.2/stenographer-v0.2.2-macos-x86_64.tar.gz"
      sha256 "3f6e5599b1217d3e34126627144ae745d90ede44edd4fa502be0e68b31d3abf0"
    end
  end

  def install
    bin.install "stenographer"
    bash_completion.install "completions/stenographer.bash" => "stenographer"
    zsh_completion.install "completions/stenographer.zsh" => "_stenographer"
    fish_completion.install "completions/stenographer.fish"
  end

  test do
    assert_match "Usage: stenographer", shell_output("#{bin}/stenographer --help")
  end
end
