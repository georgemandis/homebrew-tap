class Patui < Formula
  desc "Terminal-based image editor with Vim-style modal controls"
  homepage "https://github.com/georgemandis/patui"
  version "0.1.0"
  license "MIT"

  on_macos do
    on_arm do
      url "https://github.com/georgemandis/patui/releases/download/v0.1.0/patui-v0.1.0-macos-aarch64.tar.gz"
      sha256 "36788bd5cb6b88c93b39404c9137db5da626d392b3808ebfa25cbb76f70b35e0"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/patui/releases/download/v0.1.0/patui-v0.1.0-linux-aarch64.tar.gz"
      sha256 "8452fbe49f4ab22c26c239f867dba96422a771496564be0dd2b516b16bc61611"
    else
      url "https://github.com/georgemandis/patui/releases/download/v0.1.0/patui-v0.1.0-linux-x86_64.tar.gz"
      sha256 "206b3990322987788aaf7839114139378f4187fa343e82e42edde0eb7f27534c"
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
