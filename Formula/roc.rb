# Interim formula: installs prebuilt binaries from roc-lang/nightlies until Roc has
# a stable release that can go to homebrew-core. Kept in sync with the release in
# roc-lang.org's install_roc.sh by .github/workflows/update.yml.
class Roc < Formula
  desc "Fast, friendly, functional programming language"
  homepage "https://www.roc-lang.org"
  version "2026-11-02-847b82c"
  license "UPL-1.0"

  uses_from_macos "expect" => :test

  on_macos do
    # macOS 15 is the oldest version Roc is tested on.
    depends_on macos: :sequoia

    on_arm do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-11-02-847b82c/roc_nightly-macos_apple_silicon-2026-11-02-847b82c.tar.gz"
      sha256 "54c2e26da679b49e42513c08110ac537eb060c39fade209ffaa79a1bd26604e1"
    end
    on_intel do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-11-02-847b82c/roc_nightly-macos_x86_64-2026-11-02-847b82c.tar.gz"
      sha256 "6c8e745a21e38e72d95ee89df029cfe4bd002477fb8351392c1a69fe72eeb3e3"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-11-02-847b82c/roc_nightly-linux_arm64-2026-11-02-847b82c.tar.gz"
      sha256 "d209ea86607441c2ad082561b290bee09e0c4c330c46a67db588d63dfbe0bf14"
    end
    on_intel do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-11-02-847b82c/roc_nightly-linux_x86_64-2026-11-02-847b82c.tar.gz"
      sha256 "fe65f0eba1d5f63daaad8f86528d859150b05e4ddf40d8793a20379d2d5aaa96"
    end
  end

  # The examples revision that roc-lang.org's examples.json pins; `brew test` runs its CI script
  # on the examples that pin this formula's Roc version.
  resource "examples" do
    url "https://github.com/roc-lang/examples/archive/177750f9dd5fc47f87f72c36deab17d876592981.tar.gz"
    sha256 "f9519caec262c9360663dc3cf41baec9f25fad09722f1cf41d91d3aa13a13a4e"
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

    resource("examples").stage testpath
    # Each example pins its Roc nightly in its header; only those pinning this release must pass with it.
    pin = "roc: \"nightly-#{version}\""
    examples = (testpath/"examples").children.select do |dir|
      dir.glob("**/*.roc").any? { |file| file.read.include?(pin) }
    end
    refute_empty examples, "no example pins nightly-#{version}"
    ENV["ROC"] = bin/"roc"
    system "bash", "ci_scripts/all_tests.sh", *examples.map { |dir| dir.basename.to_s }
  end
end
