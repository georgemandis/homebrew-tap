class Patui < Formula
  desc "Terminal-based image editor with Vim-style modal controls"
  homepage "https://github.com/georgemandis/patui"
  version "0.1.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/georgemandis/patui/releases/download/v0.1.0/patui-v0.1.0-macos-aarch64.tar.gz"
      sha256 "338c11b7b0e94d3e0a03df538b5d51689c706cb62892b678ab4d4942e0b06a81"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/patui/releases/download/v0.1.0/patui-v0.1.0-linux-aarch64.tar.gz"
      sha256 "0b22cbc84cdf661a01b3377b555525374aadf87115d145e05434f2ef786ae221"
    else
      url "https://github.com/georgemandis/patui/releases/download/v0.1.0/patui-v0.1.0-linux-x86_64.tar.gz"
      sha256 "30e6e417acf8c3ea8b6e6cc2cf799645dce7c11a87d20194e47fa4828d05291c"
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
