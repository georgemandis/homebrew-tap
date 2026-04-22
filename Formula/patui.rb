class Patui < Formula
  desc "Terminal-based image editor with Vim-style modal controls"
  homepage "https://github.com/georgemandis/patui"
  version "0.2.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/georgemandis/patui/releases/download/v0.2.0/patui-v0.2.0-macos-aarch64.tar.gz"
      sha256 "136173eaa89147f9c54214d88b87ee129883c5ed23a0f0dcfdc73d1a9a52860a"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/patui/releases/download/v0.2.0/patui-v0.2.0-linux-aarch64.tar.gz"
      sha256 "ec86aa08e8845470675bba6e06c71b085bd2036d34efd1cc920ef3ea2718f321"
    else
      url "https://github.com/georgemandis/patui/releases/download/v0.2.0/patui-v0.2.0-linux-x86_64.tar.gz"
      sha256 "c6352e5616248ec925efa4b2483d053350a4077aec30676969717cc0eaaa44af"
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
