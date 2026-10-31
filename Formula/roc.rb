# Interim formula: installs prebuilt binaries from roc-lang/nightlies until Roc has
# a stable release that can go to homebrew-core. Kept in sync with the release in
# roc-lang.org's install_roc.sh by .github/workflows/update.yml.
class Roc < Formula
  desc "Fast, friendly, functional programming language"
  homepage "https://www.roc-lang.org"
  version "2026-10-30-0602c5f"
  license "UPL-1.0"

  uses_from_macos "expect" => :test

  on_macos do
    # macOS 15 is the oldest version Roc is tested on.
    depends_on macos: :sequoia

    on_arm do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-10-30-0602c5f/roc_nightly-macos_apple_silicon-2026-10-30-0602c5f.tar.gz"
      sha256 "ad3495f38b261146c187eca87889e3881260557de14d483367831f0ee542bcc9"
    end
    on_intel do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-10-30-0602c5f/roc_nightly-macos_x86_64-2026-10-30-0602c5f.tar.gz"
      sha256 "8cdd0aac3484c6c6a2500e768bcd19be624b9f0bbebaff6ab117ebff485ea2b3"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-10-30-0602c5f/roc_nightly-linux_arm64-2026-10-30-0602c5f.tar.gz"
      sha256 "5d4385c99dc4463ae1a5f355912956040108fce4397c24afb3fa62390d746da9"
    end
    on_intel do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-10-30-0602c5f/roc_nightly-linux_x86_64-2026-10-30-0602c5f.tar.gz"
      sha256 "e67256aeac4eedd99568802ec187d155e54594e40fb475f7b73005c74410c708"
    end
  end

  # The examples revision that roc-lang.org's examples.json pins; `brew test` runs its CI script
  # on the examples that pin this formula's Roc version.
  resource "examples" do
    url "https://github.com/roc-lang/examples/archive/e252bf93098eadb2e8c0b99fa1efc08b3b0caae2.tar.gz"
    sha256 "c1e85f0dea5876f47d075e1e9f1b24d4257ed85d8bf6f6504236dbfcd76531fc"
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
