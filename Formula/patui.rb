class Patui < Formula
  desc "Terminal-based image editor with Vim-style modal controls"
  homepage "https://github.com/georgemandis/patui"
  version "0.2.1"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/georgemandis/patui/releases/download/v0.2.1/patui-v0.2.1-macos-aarch64.tar.gz"
      sha256 "dd7cde4bb7f826272eb191f650797db9400a55d9ebedd4783fead057ec55ca3a"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/patui/releases/download/v0.2.1/patui-v0.2.1-linux-aarch64.tar.gz"
      sha256 "f9c27607b07686ee161410bd3ff461847bc23abb34b997dbf1833bf51f24ed70"
    else
      url "https://github.com/georgemandis/patui/releases/download/v0.2.1/patui-v0.2.1-linux-x86_64.tar.gz"
      sha256 "7fce847e5e6920e02bdc39c236c69bed51e1aa7c288eaf30dd8ae3f0bd5e2f72"
    end
  end

  def install
    libexec.install "patui"
    libexec.install "node_modules"

    (bin/"patui").write <<~SH
      #!/usr/bin/env bash
      export PATUI_CWD="$(pwd)"
      cd "#{libexec}" && exec ./patui "$@"
    SH
    chmod 0755, bin/"patui"
  end

  test do
    assert_predicate bin/"patui", :exist?
  end
end
