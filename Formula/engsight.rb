class Engsight < Formula
  desc "Personal engineering metrics, collected passively via git hooks"
  homepage "https://github.com/georgemandis/engsight"
  url "https://github.com/georgemandis/engsight/archive/refs/tags/v1.1.1.tar.gz"
  sha256 "f99d676b69928b90c258dd55a2b7c24f6ec59df169a11d208acd93d018fde474"
  version "1.1.1"
  license "MIT"

  depends_on "sqlite"

  def install
    # Install all source files to libexec
    libexec.install "engsight"
    libexec.install "common.sh"
    libexec.install "config.default"
    libexec.install "schema.sql"
    libexec.install "hooks"

    # Install MCP server
    libexec.install "mcp"

    # Make scripts executable
    chmod 0755, libexec/"engsight"

    # Create a wrapper that puts engsight in PATH
    (bin/"engsight").write <<~SH
      #!/usr/bin/env bash
      exec "#{libexec}/engsight" "$@"
    SH

    generate_completions_from_executable(bin/"engsight", "completions")
  end

  def caveats
    <<~EOS
      To complete setup, run:

        engsight setup

      This creates ~/.engsight/ with the database, config, and hook
      templates. Then install hooks in existing repos:

        engsight init          # current repo
        engsight init-all ~/Projects  # all repos under a path

      MCP server (optional, requires Bun — https://bun.sh):

        cd #{libexec}/mcp && bun install
        claude mcp add engsight -s user -- bun run #{libexec}/mcp/index.ts
    EOS
  end

  test do
    assert_match "Usage: engsight", shell_output("#{bin}/engsight --help")
  end
end
