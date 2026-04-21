class Patui < Formula
  desc "Terminal-based image editor with Vim-style modal controls"
  homepage "https://github.com/georgemandis/patui"
  version "0.1.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/georgemandis/patui/releases/download/v0.1.0/patui-v0.1.0-macos-aarch64.tar.gz"
      sha256 "8eaf4d71864531b2f1007f54b23e2cd2decd07bc0dbb7fb7b0153bf5c5c6db67"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/patui/releases/download/v0.1.0/patui-v0.1.0-linux-aarch64.tar.gz"
      sha256 "72bd57d687bd7d3343316f51e09658dff85d9822d9c4c94effa6334ce432333e"
    else
      url "https://github.com/georgemandis/patui/releases/download/v0.1.0/patui-v0.1.0-linux-x86_64.tar.gz"
      sha256 "9a466c859e41226a01db90341198093de1028ab5eebad6c2b8e758e3b045f845"
    end
  end

  def install
    bin.install "patui"
    libexec.install "sharp"

    # Wrapper so the binary can find sharp's native bindings
    mv bin/"patui", libexec/"patui"
    (bin/"patui").write <<~SH
      #!/usr/bin/env bash
      NODE_PATH="#{libexec}/sharp" exec "#{libexec}/patui" "$@"
    SH
    chmod 0755, bin/"patui"
  end

  test do
    assert_match "patui", (bin/"patui").read
  end
end
