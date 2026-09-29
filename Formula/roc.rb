# Interim formula: installs prebuilt binaries from roc-lang/nightlies until Roc has
# a stable release that can go to homebrew-core. Bumped by .github/workflows/update.yml.
class Roc < Formula
  desc "Fast, friendly, functional programming language"
  homepage "https://www.roc-lang.org"
  version "2026-09-23-c7852fd"
  license "UPL-1.0"

  on_macos do
    # macOS 15 is the oldest version Roc is tested on.
    depends_on macos: :sequoia

    on_arm do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-09-23-c7852fd/roc_nightly-macos_apple_silicon-2026-09-23-c7852fd.tar.gz"
      sha256 "a1035f23a8c2ac80b804a3f6b806a05fb87f6844202a50bbb71adb05b098b131"
    end
    on_intel do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-09-23-c7852fd/roc_nightly-macos_x86_64-2026-09-23-c7852fd.tar.gz"
      sha256 "7be7c4f1b5ba43f62113351116907db4ca894e5477cbe96aa27187a7b856c0b5"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-09-23-c7852fd/roc_nightly-linux_arm64-2026-09-23-c7852fd.tar.gz"
      sha256 "50e8095bd9f3358ac40bc446f6bc2e06a83f190877a0eebc631e27d22ecf80b6"
    end
    on_intel do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-09-23-c7852fd/roc_nightly-linux_x86_64-2026-09-23-c7852fd.tar.gz"
      sha256 "e1be77f68bc71b1422e66810f3a57230b26b6c46ee95af8e7ee6027fccab94c0"
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
