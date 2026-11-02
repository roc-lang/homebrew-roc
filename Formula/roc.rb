# Interim formula: installs prebuilt binaries from roc-lang/nightlies until Roc has
# a stable release that can go to homebrew-core. Kept in sync with the release in
# roc-lang.org's install_roc.sh by .github/workflows/update.yml.
class Roc < Formula
  desc "Fast, friendly, functional programming language"
  homepage "https://www.roc-lang.org"
  version "2026-10-31-f7bef6b"
  license "UPL-1.0"

  uses_from_macos "expect" => :test

  on_macos do
    # macOS 15 is the oldest version Roc is tested on.
    depends_on macos: :sequoia

    on_arm do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-10-31-f7bef6b/roc_nightly-macos_apple_silicon-2026-10-31-f7bef6b.tar.gz"
      sha256 "722701117cc7003b654ee07b5e1b2c5fc6e03fe9ca7c48ea6da905fe7708da5c"
    end
    on_intel do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-10-31-f7bef6b/roc_nightly-macos_x86_64-2026-10-31-f7bef6b.tar.gz"
      sha256 "7b723e23a71569ac9d0d2b2f088d0df6f9421acd6f3450df35c2fcd9ee6d0a6d"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-10-31-f7bef6b/roc_nightly-linux_arm64-2026-10-31-f7bef6b.tar.gz"
      sha256 "88325bdc3938dec9197a3a8e3661586b82d3b02e7916b87b0509d862cec3b03b"
    end
    on_intel do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-10-31-f7bef6b/roc_nightly-linux_x86_64-2026-10-31-f7bef6b.tar.gz"
      sha256 "21d43a205233e35cd6c3e0e95a2ac18102ef58055e77e82f2ee91d02885bf8fd"
    end
  end

  # The examples revision that roc-lang.org's examples.json pins; `brew test` runs its CI script
  # on the examples that pin this formula's Roc version.
  resource "examples" do
    url "https://github.com/roc-lang/examples/archive/6f4940a1dcb8de0623be07248a41c7402649f0c3.tar.gz"
    sha256 "559c02c6e37b4ebab374a04e5cb0137f3f1e9154d4819ecf9d683628a7c17e25"
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
