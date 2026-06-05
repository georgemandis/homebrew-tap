class Nearme < Formula
  desc "Search for places near you from the command line using native macOS APIs"
  homepage "https://github.com/georgemandis/nearme"
  version "0.3.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/nearme/releases/download/v0.3.0/nearme-v0.3.0-macos-aarch64.tar.gz"
      sha256 "e1060ae1113d5601fa96aaf9b24c03991a7b1af2cb60f785b81b0823bd5d8dd9"
    else
      url "https://github.com/georgemandis/nearme/releases/download/v0.3.0/nearme-v0.3.0-macos-x86_64.tar.gz"
      sha256 "8b4426f24ddde7173995395dad21f8220bba304ea50f0fd81c8bb16506c4e0bd"
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
