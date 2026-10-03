# Interim formula: installs prebuilt binaries from roc-lang/nightlies until Roc has
# a stable release that can go to homebrew-core. Bumped by .github/workflows/update.yml.
class Roc < Formula
  desc "Fast, friendly, functional programming language"
  homepage "https://www.roc-lang.org"
  version "2026-10-03-c507926"
  license "UPL-1.0"

  on_macos do
    # macOS 15 is the oldest version Roc is tested on.
    depends_on macos: :sequoia

    on_arm do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-10-03-c507926/roc_nightly-macos_apple_silicon-2026-10-03-c507926.tar.gz"
      sha256 "890dc5a3129d0af6de21a88434104190b71abcc2f9fa17adb2378dc9fb80ea63"
    end
    on_intel do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-10-03-c507926/roc_nightly-macos_x86_64-2026-10-03-c507926.tar.gz"
      sha256 "09efaf507acdb669de9bb03255a0e012e28a6168ae414accbf2b3967f58ed474"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-10-03-c507926/roc_nightly-linux_arm64-2026-10-03-c507926.tar.gz"
      sha256 "e26371cac7cff21bb6353a8c2780fdecf33ff27ea62c103c9f01aa1481a0b292"
    end
    on_intel do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-10-03-c507926/roc_nightly-linux_x86_64-2026-10-03-c507926.tar.gz"
      sha256 "fe0e1aa9f01c724cca2d564374eeb205c88e2d28c80045f568efbe1f4b3e0e74"
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
