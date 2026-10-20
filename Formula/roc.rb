# Interim formula: installs prebuilt binaries from roc-lang/nightlies until Roc has
# a stable release that can go to homebrew-core. Kept in sync with the release in
# roc-lang.org's install_roc.sh by .github/workflows/update.yml.
class Roc < Formula
  desc "Fast, friendly, functional programming language"
  homepage "https://www.roc-lang.org"
  version "2026-10-18-1df370f"
  license "UPL-1.0"

  uses_from_macos "expect" => :test

  on_macos do
    # macOS 15 is the oldest version Roc is tested on.
    depends_on macos: :sequoia

    on_arm do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-10-18-1df370f/roc_nightly-macos_apple_silicon-2026-10-18-1df370f.tar.gz"
      sha256 "0f5fe1d12714bf5fcc906dd5b00fd0ccd31dfb96bb82737b9d6f6ccc0e93c147"
    end
    on_intel do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-10-18-1df370f/roc_nightly-macos_x86_64-2026-10-18-1df370f.tar.gz"
      sha256 "3febd84c0ff274cf3da2fa71afafe4a8039a11c68d774d48406ab669627dce96"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-10-18-1df370f/roc_nightly-linux_arm64-2026-10-18-1df370f.tar.gz"
      sha256 "50058449e786bf9bded19ca3b851a1c030fea7fc8ac8aebed2c7c12a37505ac4"
    end
    on_intel do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-10-18-1df370f/roc_nightly-linux_x86_64-2026-10-18-1df370f.tar.gz"
      sha256 "0821ea1a9772f921f0b4eb1cd400238abb59b0247db2810f0ea865426f782e9d"
    end
  end

  # The examples revision that roc-lang.org's examples.json pins; `brew test` runs its CI script
  # on the examples that pin this formula's Roc version.
  resource "examples" do
    url "https://github.com/roc-lang/examples/archive/3af56635b4318b02249f6662bdaa3a97094458f3.tar.gz"
    sha256 "037d0ffeb347f448f1ea55aa6024d37c185bc820f157918f0470fdd0a78a75ff"
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
