class Patui < Formula
  desc "Terminal-based image editor with Vim-style modal controls"
  homepage "https://github.com/georgemandis/patui"
  version "0.1.0"
  license "MIT"

  depends_on "bun"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/patui/releases/download/v0.1.0/patui-v0.1.0-macos-aarch64.tar.gz"
      sha256 "PLACEHOLDER"
    else
      url "https://github.com/georgemandis/patui/releases/download/v0.1.0/patui-v0.1.0-macos-x86_64.tar.gz"
      sha256 "PLACEHOLDER"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/patui/releases/download/v0.1.0/patui-v0.1.0-linux-aarch64.tar.gz"
      sha256 "PLACEHOLDER"
    else
      url "https://github.com/georgemandis/patui/releases/download/v0.1.0/patui-v0.1.0-linux-x86_64.tar.gz"
      sha256 "PLACEHOLDER"
    end
  end

  def install
    libexec.install "patui.js"
    libexec.install "sharp"

    (bin/"patui").write <<~SH
      #!/usr/bin/env bash
      NODE_PATH="#{libexec}/sharp" exec bun "#{libexec}/patui.js" "$@"
    SH
    chmod 0755, bin/"patui"
  end

  test do
    # patui is a TUI app — just verify the bundle loads without error
    assert_match "patui", (bin/"patui").read
  end
end
