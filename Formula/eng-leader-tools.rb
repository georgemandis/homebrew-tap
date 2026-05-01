class EngLeaderTools < Formula
  desc "Bash scripts for engineering leadership metrics — DORA, PR health, review load, and more"
  homepage "https://github.com/georgemandis/eng-leader-tools"
  url "https://github.com/georgemandis/eng-leader-tools/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "f0417db068510f43a33125bf558be881098072b7d4a4a953d1311f5c2717c682"
  version "0.1.0"
  license "MIT"

  depends_on "gh"
  depends_on "jq"

  def install
    # Install all scripts to libexec
    libexec.install Dir["*.sh"]
    libexec.install "eng"

    # Symlink the eng wrapper into bin
    bin.install_symlink libexec/"eng"

    # Install shell completions
    bash_completion.install Utils.safe_popen_read(libexec/"eng", "--completions", "bash").to_s => "eng"
    zsh_completion.install Utils.safe_popen_read(libexec/"eng", "--completions", "zsh").to_s => "_eng"
    fish_completion.install Utils.safe_popen_read(libexec/"eng", "--completions", "fish").to_s => "eng.fish"
  end

  test do
    assert_match "eng v#{version}", shell_output("#{bin}/eng --version")
    assert_match "DORA Metrics", shell_output("#{bin}/eng --help")
  end
end
