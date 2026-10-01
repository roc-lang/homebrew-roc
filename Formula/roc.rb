# Interim formula: installs prebuilt binaries from roc-lang/nightlies until Roc has
# a stable release that can go to homebrew-core. Bumped by .github/workflows/update.yml.
class Roc < Formula
  desc "Fast, friendly, functional programming language"
  homepage "https://www.roc-lang.org"
  version "2026-10-01-a932c65"
  license "UPL-1.0"

  on_macos do
    # macOS 15 is the oldest version Roc is tested on.
    depends_on macos: :sequoia

    on_arm do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-10-01-a932c65/roc_nightly-macos_apple_silicon-2026-10-01-a932c65.tar.gz"
      sha256 "a0ed55a897ba6645a49bab32e9e24c031761afa5f0c60c2e145ca0829859193d"
    end
    on_intel do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-10-01-a932c65/roc_nightly-macos_x86_64-2026-10-01-a932c65.tar.gz"
      sha256 "6669ddaff2e0ae39a2b172ff828a57ffced5c0362b0776b3d0cc07e36bb1ba3f"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-10-01-a932c65/roc_nightly-linux_arm64-2026-10-01-a932c65.tar.gz"
      sha256 "251cf9b647555671b6ac8ceee0e896199674b9844e2685d729898ae38dd341a8"
    end
    on_intel do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-10-01-a932c65/roc_nightly-linux_x86_64-2026-10-01-a932c65.tar.gz"
      sha256 "0f6490fe275d95efe0f4f649a92f70c14f0d4eb43da8797cf9d312b49cd1fa41"
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
