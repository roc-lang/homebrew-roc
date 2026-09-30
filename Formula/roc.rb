# Interim formula: installs prebuilt binaries from roc-lang/nightlies until Roc has
# a stable release that can go to homebrew-core. Bumped by .github/workflows/update.yml.
class Roc < Formula
  desc "Fast, friendly, functional programming language"
  homepage "https://www.roc-lang.org"
  version "2026-09-29-7f11a82"
  license "UPL-1.0"

  on_macos do
    # macOS 15 is the oldest version Roc is tested on.
    depends_on macos: :sequoia

    on_arm do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-09-29-7f11a82/roc_nightly-macos_apple_silicon-2026-09-29-7f11a82.tar.gz"
      sha256 "f382f4b088cb2cb203e880d7b5712a9e062604925cbc22a6b2d83a5df0e2dac0"
    end
    on_intel do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-09-29-7f11a82/roc_nightly-macos_x86_64-2026-09-29-7f11a82.tar.gz"
      sha256 "4051947326003b58e65826a1f2cd7bc4717a47ecec82aa71cc6705b2512cb248"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-09-29-7f11a82/roc_nightly-linux_arm64-2026-09-29-7f11a82.tar.gz"
      sha256 "3230f442092fdb076cdcd6223f195396a6749ee382e3e00e05e78e731bcb8e6b"
    end
    on_intel do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-09-29-7f11a82/roc_nightly-linux_x86_64-2026-09-29-7f11a82.tar.gz"
      sha256 "3f3911f8386cb34561f9fc93a1d04bf1c1a8a0f4c4c9785d9f0291dc8d10fd15"
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
