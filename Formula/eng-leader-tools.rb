class EngLeaderTools < Formula
  desc "Bash scripts for engineering leadership metrics — DORA, PR health, review load, and more"
  homepage "https://github.com/georgemandis/eng-leader-tools"
  url "https://github.com/georgemandis/eng-leader-tools/archive/refs/tags/v0.3.2.tar.gz"
  sha256 "f38c1f896995f11473fec9a2be71699d24af829f71bdf8dbc57652db85ba305a"
  version "0.3.2"
  license "MIT"

  depends_on "gh"
  depends_on "jq"

  # Compiled MCP server binary (eng-mcp), per platform. URLs use literal
  # version strings so update.sh can version-bump them; hashes are filled by
  # update.sh once the release assets exist.
  on_macos do
    on_arm do
      resource "eng-mcp" do
        url "https://github.com/georgemandis/eng-leader-tools/releases/download/v0.3.2/eng-mcp-v0.3.2-macos-aarch64.tar.gz"
        sha256 "36272755b616c74391df51380dad5a82db86422568b55c0e81e7bf810a7fa5ff"
      end
    end
    on_intel do
      resource "eng-mcp" do
        url "https://github.com/georgemandis/eng-leader-tools/releases/download/v0.3.2/eng-mcp-v0.3.2-macos-x86_64.tar.gz"
        sha256 "c0ee6f3077734911757d9285ea9b0517edb354a0898874539e6bf096910eee65"
      end
    end
  end
  on_linux do
    resource "eng-mcp" do
      url "https://github.com/georgemandis/eng-leader-tools/releases/download/v0.3.2/eng-mcp-v0.3.2-linux-x86_64.tar.gz"
      sha256 "74605e3621f34ddbe7220381fa7a1ed0e64c60aadbb01d3a58a737e22628329a"
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
