class Stenographer < Formula
  desc "Speech-to-text from the command line using native macOS Speech Recognition"
  homepage "https://github.com/georgemandis/stenographer"
  version "0.2.1"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/georgemandis/stenographer/releases/download/v0.2.1/stenographer-v0.2.1-macos-aarch64.tar.gz"
      sha256 "3f4b75f6ec7bc9b57abee9deb4bc56f2f9bdd97e2b36964a6942112e3446b987"
    else
      url "https://github.com/georgemandis/stenographer/releases/download/v0.2.1/stenographer-v0.2.1-macos-x86_64.tar.gz"
      sha256 "5411f3be285453a8b42e59807f0d35c4e613e3bb6995042359bee7a17d28d142"
    end
  end

  def install
    bin.install "stenographer"
    bash_completion.install "completions/stenographer.bash" => "stenographer"
    zsh_completion.install "completions/stenographer.zsh" => "_stenographer"
    fish_completion.install "completions/stenographer.fish"
  end

  test do
    assert_match "Usage: stenographer", shell_output("#{bin}/stenographer --help")
  end
end
