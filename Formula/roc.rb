# Interim formula: installs prebuilt binaries from roc-lang/nightlies until Roc has
# a stable release that can go to homebrew-core. Bumped by .github/workflows/update.yml.
class Roc < Formula
  desc "Fast, friendly, functional programming language"
  homepage "https://www.roc-lang.org"
  version "2026-10-02-bba1acc"
  license "UPL-1.0"

  on_macos do
    # macOS 15 is the oldest version Roc is tested on.
    depends_on macos: :sequoia

    on_arm do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-10-02-bba1acc/roc_nightly-macos_apple_silicon-2026-10-02-bba1acc.tar.gz"
      sha256 "1d114ad027c02b918e5a71c8686a3488b708f3e794126216e0441590e233712f"
    end
    on_intel do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-10-02-bba1acc/roc_nightly-macos_x86_64-2026-10-02-bba1acc.tar.gz"
      sha256 "600f70339b86f5e72d8c0bd6fbf43064bb2ae882c37bf1cc580dae34830993bd"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-10-02-bba1acc/roc_nightly-linux_arm64-2026-10-02-bba1acc.tar.gz"
      sha256 "a661973fda1b8b8545475342f97402f1c659ef5bec282e2988a4f08f0ebccef8"
    end
    on_intel do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-10-02-bba1acc/roc_nightly-linux_x86_64-2026-10-02-bba1acc.tar.gz"
      sha256 "ccce93938d2279d4f0b28439ea150a0cac21a96f528ea7ac9daddb04760e57fe"
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
