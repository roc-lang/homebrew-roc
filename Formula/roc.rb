# Interim formula: installs prebuilt binaries from roc-lang/nightlies until Roc has
# a stable release that can go to homebrew-core. Bumped by .github/workflows/update.yml.
class Roc < Formula
  desc "Fast, friendly, functional programming language"
  homepage "https://www.roc-lang.org"
  version "2026-10-09-258ab27"
  license "UPL-1.0"

  on_macos do
    # macOS 15 is the oldest version Roc is tested on.
    depends_on macos: :sequoia

    on_arm do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-10-09-258ab27/roc_nightly-macos_apple_silicon-2026-10-09-258ab27.tar.gz"
      sha256 "aa6339579730fcea4753940bec21f5d8cf8be8e25659ec001abccbc3463a60b2"
    end
    on_intel do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-10-09-258ab27/roc_nightly-macos_x86_64-2026-10-09-258ab27.tar.gz"
      sha256 "ac04c74946e14cbf878b6344b6e7c79aea741f0868e03f380ee307db62507776"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-10-09-258ab27/roc_nightly-linux_arm64-2026-10-09-258ab27.tar.gz"
      sha256 "9750ce89a820d3cdeadd751996d26c70b68584ca9428e52f43a1bb20702c54e5"
    end
    on_intel do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-10-09-258ab27/roc_nightly-linux_x86_64-2026-10-09-258ab27.tar.gz"
      sha256 "dcb99abdf17d062246c05e394357ad682b883a6bcff7b2e581e20564ea88ffc4"
    end
  end

  def install
    # roc links against the `darwin` sysroot next to its symlink-resolved path, so keep them together.
    libexec.install "roc"
    libexec.install "darwin" if OS.mac?
    bin.install_symlink libexec/"roc"
    prefix.install "legal_details"
  end

  test do
    assert_equal "Roc compiler version nightly-#{version}", shell_output("#{bin}/roc version").strip

    # Headerless apps use the built-in Echo platform, so this needs no network.
    (testpath/"hello.roc").write <<~ROC
      main! = |_args| {
          echo!("Hello, World!")
          Ok({})
      }
    ROC
    system bin/"roc", "build", "hello.roc"
    assert_equal "Hello, World!", shell_output("./hello").strip
  end
end
