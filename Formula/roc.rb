# Interim formula: installs prebuilt binaries from roc-lang/nightlies until Roc has
# a stable release that can go to homebrew-core. Kept in sync with the release in
# roc-lang.org's install_roc.sh by .github/workflows/update.yml.
class Roc < Formula
  desc "Fast, friendly, functional programming language"
  homepage "https://www.roc-lang.org"
  version "2026-10-27-de79a0f"
  license "UPL-1.0"

  uses_from_macos "expect" => :test

  on_macos do
    # macOS 15 is the oldest version Roc is tested on.
    depends_on macos: :sequoia

    on_arm do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-10-27-de79a0f/roc_nightly-macos_apple_silicon-2026-10-27-de79a0f.tar.gz"
      sha256 "7dee228e7024472b240401fb669f30a8e13c37286e1bb7102772114fe5a4c094"
    end
    on_intel do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-10-27-de79a0f/roc_nightly-macos_x86_64-2026-10-27-de79a0f.tar.gz"
      sha256 "d8ae1184e7ffdff225b90aaa94399d4c1f97500a20e46c389c4a8b02eb03d87f"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-10-27-de79a0f/roc_nightly-linux_arm64-2026-10-27-de79a0f.tar.gz"
      sha256 "99d3fe58a7995e61a672a8b19ff82c6f9edfa5b1d099f1bccf8418121ebef62c"
    end
    on_intel do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-10-27-de79a0f/roc_nightly-linux_x86_64-2026-10-27-de79a0f.tar.gz"
      sha256 "1efa0bf74d93964c270e60761ed6148f2e132c3adfcc5361149b518ef8488649"
    end
  end

  # The examples revision that roc-lang.org's examples.json pins; `brew test` runs its CI script
  # on the examples that pin this formula's Roc version.
  resource "examples" do
    url "https://github.com/roc-lang/examples/archive/d1ed73a5dde9415421d1d55b5d1bf41136db977a.tar.gz"
    sha256 "281256700589735bba8aa4f486a58a37b75aed007504193946dff8ee21bd062b"
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
