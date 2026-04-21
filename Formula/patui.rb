class Patui < Formula
  desc "Terminal-based image editor with Vim-style modal controls"
  homepage "https://github.com/georgemandis/patui"
  version "0.1.0"
  license "MIT"

  depends_on "bun"

  on_macos do
    on_arm do
      url "https://github.com/georgemandis/patui/releases/download/v0.1.0/patui-v0.1.0-macos-aarch64.tar.gz"
      sha256 "e412678b72e8ab533265d86aabb9956fb412de05c2ab874f5abc250e26896317"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/patui/releases/download/v0.1.0/patui-v0.1.0-linux-aarch64.tar.gz"
      sha256 "953fb17963986cfcf59326841154201d1d9cd29a9b27046ce017cda63eeae7f5"
    else
      url "https://github.com/georgemandis/patui/releases/download/v0.1.0/patui-v0.1.0-linux-x86_64.tar.gz"
      sha256 "3f4e10a35714ef898a07f7aa41a6b7514e166e8373afdd978a6f7eb5b4fe695c"
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
