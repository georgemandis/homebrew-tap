class Nearme < Formula
  desc "Search for places near you from the command line using native macOS APIs"
  homepage "https://github.com/georgemandis/nearme"
  version "0.2.1"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/nearme/releases/download/v0.2.1/nearme-v0.2.1-macos-aarch64.tar.gz"
      sha256 "333a1401ad7aef92fcccd6c10cde9ff599772f35cd54f0fd896dea52a9667453"
    else
      url "https://github.com/georgemandis/nearme/releases/download/v0.2.1/nearme-v0.2.1-macos-x86_64.tar.gz"
      sha256 "2d27fd7e9daca151ca4d8f158359b7a1a0c670f940f1185bd6353ed84494a82f"
    end
  end

  def install
    bin.install "nearme"

    # Generate and install shell completions
    (buildpath/"nearme.bash").write Utils.safe_popen_read(bin/"nearme", "--completions=bash")
    (buildpath/"_nearme").write Utils.safe_popen_read(bin/"nearme", "--completions=zsh")
    (buildpath/"nearme.fish").write Utils.safe_popen_read(bin/"nearme", "--completions=fish")
    bash_completion.install buildpath/"nearme.bash" => "nearme"
    zsh_completion.install buildpath/"_nearme"
    fish_completion.install buildpath/"nearme.fish"
  end

  test do
    assert_match "Usage: nearme", shell_output("#{bin}/nearme --help")
  end
end
