class Engsight < Formula
  desc "Personal engineering metrics, collected passively via git hooks"
  homepage "https://github.com/georgemandis/engsight"
  url "https://github.com/georgemandis/engsight/archive/refs/tags/v1.0.0.tar.gz"
  sha256 "bf2af050c873095dfa79f2ed128ef44d35b19ef403c2189cf6c346e76a8ba8f8"
  version "1.0.0"
  license "MIT"

  depends_on "sqlite"

  def install
    # Install all source files to libexec
    libexec.install "engsight"
    libexec.install "common.sh"
    libexec.install "config.default"
    libexec.install "schema.sql"
    libexec.install "install.sh"
    libexec.install "hooks"

    # Make scripts executable
    chmod 0755, libexec/"engsight"
    chmod 0755, libexec/"install.sh"

    # Create a wrapper that puts engsight in PATH
    (bin/"engsight").write <<~SH
      #!/usr/bin/env bash
      exec "#{libexec}/engsight" "$@"
    SH
  end

  def caveats
    <<~EOS
      To complete setup, run:

        #{libexec}/install.sh

      This creates ~/.engsight/ with the database, config, and hook
      templates. Then install hooks in existing repos:

        engsight init          # current repo
        engsight init-all ~/Projects  # all repos under a path
    EOS
  end

  test do
    assert_match "Usage: engsight", shell_output("#{bin}/engsight --help")
  end
end
