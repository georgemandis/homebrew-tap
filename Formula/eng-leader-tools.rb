class EngLeaderTools < Formula
  desc "Bash scripts for engineering leadership metrics — DORA, PR health, review load, and more"
  homepage "https://github.com/georgemandis/eng-leader-tools"
  url "https://github.com/georgemandis/eng-leader-tools/archive/refs/tags/v0.3.3.tar.gz"
  sha256 "6e2df9937f98f1baeed489623407f8c1d8c2e16427fbcde0764c87c77160cd78"
  version "0.3.3"
  license "MIT"

  depends_on "gh"
  depends_on "jq"

  # Compiled MCP server binary (eng-mcp), per platform. URLs use literal
  # version strings so update.sh can version-bump them; hashes are filled by
  # update.sh once the release assets exist.
  on_macos do
    on_arm do
      resource "eng-mcp" do
        url "https://github.com/georgemandis/eng-leader-tools/releases/download/v0.3.3/eng-mcp-v0.3.3-macos-aarch64.tar.gz"
        sha256 "28a21661bcc5aabd59c76a3e7181b08416e21eec73a74d370a669872c42c1245"
      end
    end
  end
  on_linux do
    resource "eng-mcp" do
      url "https://github.com/georgemandis/eng-leader-tools/releases/download/v0.3.3/eng-mcp-v0.3.3-linux-x86_64.tar.gz"
      sha256 "1b9684e4b100ff81debe96068ac72aca87c463879ee2cc2be1b0ca959f48cc78"
    end
  end

  def install
    # Install all scripts to libexec
    libexec.install "src"
    libexec.install "eng"

    # Install the compiled MCP server binary beside eng
    resource("eng-mcp").stage { libexec.install "eng-mcp" }

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
