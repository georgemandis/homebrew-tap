class EngLeaderTools < Formula
  desc "Bash scripts for engineering leadership metrics — DORA, PR health, review load, and more"
  homepage "https://github.com/georgemandis/eng-leader-tools"
  url "https://github.com/georgemandis/eng-leader-tools/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "d1a2eb65fd7228b66e8020a4cab52ddffa367b13b8e9e5dc08a922e0959f4d5d"
  version "0.3.0"
  license "MIT"

  depends_on "gh"
  depends_on "jq"

  def install
    # Install all scripts to libexec
    libexec.install "src"
    libexec.install "eng"

    # Symlink the eng wrapper into bin
    bin.install_symlink libexec/"eng"

    # Generate and install shell completions
    (buildpath/"eng.bash").write Utils.safe_popen_read(libexec/"eng", "--completions", "bash")
    (buildpath/"_eng").write Utils.safe_popen_read(libexec/"eng", "--completions", "zsh")
    (buildpath/"eng.fish").write Utils.safe_popen_read(libexec/"eng", "--completions", "fish")
    bash_completion.install buildpath/"eng.bash" => "eng"
    zsh_completion.install buildpath/"_eng"
    fish_completion.install buildpath/"eng.fish"
  end

  test do
    assert_match "eng v#{version}", shell_output("#{bin}/eng --version")
    assert_match "DORA Metrics", shell_output("#{bin}/eng --help")
  end
end
