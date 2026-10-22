# Interim formula: installs prebuilt binaries from roc-lang/nightlies until Roc has
# a stable release that can go to homebrew-core. Kept in sync with the release in
# roc-lang.org's install_roc.sh by .github/workflows/update.yml.
class Roc < Formula
  desc "Fast, friendly, functional programming language"
  homepage "https://www.roc-lang.org"
  version "2026-10-21-5349569"
  license "UPL-1.0"

  uses_from_macos "expect" => :test

  on_macos do
    # macOS 15 is the oldest version Roc is tested on.
    depends_on macos: :sequoia

    on_arm do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-10-21-5349569/roc_nightly-macos_apple_silicon-2026-10-21-5349569.tar.gz"
      sha256 "a8a81b5436c69eb5bf14ddc48bd9f0ef71326fd485340a4a1a7a683db442e5a6"
    end
    on_intel do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-10-21-5349569/roc_nightly-macos_x86_64-2026-10-21-5349569.tar.gz"
      sha256 "31b1c15f5627a7144e66c26695bd3fd11c1dac2f619c256398f9134c7cc9bec6"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-10-21-5349569/roc_nightly-linux_arm64-2026-10-21-5349569.tar.gz"
      sha256 "cb6cbe82e45ba284d5b01910e8e91a978701ffed3c2baf2c9a88baa4adc369f5"
    end
    on_intel do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-10-21-5349569/roc_nightly-linux_x86_64-2026-10-21-5349569.tar.gz"
      sha256 "70346ac60dd0b0507881447c5b47aed799fd1bea01c50bac56f82ed96897f4df"
    end
  end

  # The examples revision that roc-lang.org's examples.json pins; `brew test` runs its CI script
  # on the examples that pin this formula's Roc version.
  resource "examples" do
    url "https://github.com/roc-lang/examples/archive/3066ff92d6c1b6fbdf048a0a41ccf4081bd35e1e.tar.gz"
    sha256 "9f9795928ceb7f07d442aaeccbd7d4a4c02c6e995a1daad6ed88730861dace7b"
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
