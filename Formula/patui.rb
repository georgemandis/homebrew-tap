class Patui < Formula
  desc "Terminal-based image editor with Vim-style modal controls"
  homepage "https://github.com/georgemandis/patui"
  version "0.3.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/georgemandis/patui/releases/download/v0.3.0/patui-v0.3.0-macos-aarch64.tar.gz"
      sha256 "3c36f2eab6dce794d75a4576ceec3e250156aeead2342cc6e779f49a737ee4f5"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/patui/releases/download/v0.3.0/patui-v0.3.0-linux-aarch64.tar.gz"
      sha256 "bc239762697b24a1625015776c37a4a8f4a57174f434775ce08ab99bbf084b6a"
    else
      url "https://github.com/georgemandis/patui/releases/download/v0.3.0/patui-v0.3.0-linux-x86_64.tar.gz"
      sha256 "78dca258a377e4c83d91f224d984845f7ee6fa6a4158fd9c43c2fe2ae88da02f"
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
    assert_path_exists bin/"patui"
  end
end
