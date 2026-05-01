class EngLeaderTools < Formula
  desc "Bash scripts for engineering leadership metrics — DORA, PR health, review load, and more"
  homepage "https://github.com/georgemandis/eng-leader-tools"
  url "https://github.com/georgemandis/eng-leader-tools/archive/refs/tags/v0.1.2.tar.gz"
  sha256 "606efe83705c58553bae5a3e0ae2a4bdda7049185ae2ac6e6aceee3cae42986d"
  version "0.1.2"
  license "MIT"

  depends_on "gh"
  depends_on "jq"

  def install
    # Install all scripts to libexec
    libexec.install Dir["*.sh"]
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
