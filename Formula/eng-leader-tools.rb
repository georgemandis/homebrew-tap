class EngLeaderTools < Formula
  desc "Bash scripts for engineering leadership metrics — DORA, PR health, review load, and more"
  homepage "https://github.com/georgemandis/eng-leader-tools"
  url "https://github.com/georgemandis/eng-leader-tools/archive/refs/tags/v0.3.4.tar.gz"
  sha256 "5f7b8e712e22222bb8af4b79983431b31af132e61b15acc40bb14d23714aff8f"
  version "0.3.4"
  license "MIT"

  depends_on "gh"
  depends_on "jq"

  # Compiled MCP server binary (eng-mcp), per platform. URLs use literal
  # version strings so update.sh can version-bump them; hashes are filled by
  # update.sh once the release assets exist.
  on_macos do
    on_arm do
      resource "eng-mcp" do
        url "https://github.com/georgemandis/eng-leader-tools/releases/download/v0.3.4/eng-mcp-v0.3.4-macos-aarch64.tar.gz"
        sha256 "e40d5de4b803ad21619ae03fde065ee1b8c0eac08801d838bf9d4ef732449b6b"
      end
    end
  end
  on_linux do
    resource "eng-mcp" do
      url "https://github.com/georgemandis/eng-leader-tools/releases/download/v0.3.4/eng-mcp-v0.3.4-linux-x86_64.tar.gz"
      sha256 "c036b11ad60229a6b27fcf54121a2b88bbdc52cc968204aea9a6c7edee7c17a6"
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
