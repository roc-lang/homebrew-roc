# Interim formula: installs prebuilt binaries from roc-lang/nightlies until Roc has
# a stable release that can go to homebrew-core. Bumped by .github/workflows/update.yml.
class Roc < Formula
  desc "Fast, friendly, functional programming language"
  homepage "https://www.roc-lang.org"
  version "2026-10-06-c34079d"
  license "UPL-1.0"

  on_macos do
    # macOS 15 is the oldest version Roc is tested on.
    depends_on macos: :sequoia

    on_arm do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-10-06-c34079d/roc_nightly-macos_apple_silicon-2026-10-06-c34079d.tar.gz"
      sha256 "78ef3fc25161d908321d2dae2b9053bc03a1e946f8528d78aec594c2f401a5ed"
    end
    on_intel do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-10-06-c34079d/roc_nightly-macos_x86_64-2026-10-06-c34079d.tar.gz"
      sha256 "7a04bab76328e90363fffe174c275debc8c9d964f2940ac74edd48478d0c6229"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-10-06-c34079d/roc_nightly-linux_arm64-2026-10-06-c34079d.tar.gz"
      sha256 "1efdc8c4dbb813cff10254a13d75822162a7dde8cfc93afa93c2c2b545ce02d4"
    end
    on_intel do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-10-06-c34079d/roc_nightly-linux_x86_64-2026-10-06-c34079d.tar.gz"
      sha256 "11bf5c73b81e517ae2807f4211fe9e996f48f87a68b1e85b82c4ae2c6499a5d6"
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
