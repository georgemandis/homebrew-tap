class Patui < Formula
  desc "Terminal-based image editor with Vim-style modal controls"
  homepage "https://github.com/georgemandis/patui"
  version "0.1.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/georgemandis/patui/releases/download/v0.1.0/patui-v0.1.0-macos-aarch64.tar.gz"
      sha256 "8453709f9d46732fbabffe1acea767b4c8a2a68cc37e52fd21115c7f5625e7cb"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/patui/releases/download/v0.1.0/patui-v0.1.0-linux-aarch64.tar.gz"
      sha256 "544bf178e6921bc34db80b2593299bce44cf472630b197b41797e12dc80566f7"
    else
      url "https://github.com/georgemandis/patui/releases/download/v0.1.0/patui-v0.1.0-linux-x86_64.tar.gz"
      sha256 "2279b412734f3d523388bb22c19cfbdda4837c2fc85f9569fb95d3d2befcb577"
    end
  end

  def install
    libexec.install "patui"
    libexec.install "node_modules"

    (bin/"patui").write <<~SH
      #!/usr/bin/env bash
      cd "#{libexec}" && exec ./patui "$@"
    SH
    chmod 0755, bin/"patui"
  end

  test do
    assert_predicate bin/"patui", :exist?
  end
end
