# Interim formula: installs prebuilt binaries from roc-lang/nightlies until Roc has
# a stable release that can go to homebrew-core. Kept in sync with the release in
# roc-lang.org's install_roc.sh by .github/workflows/update.yml.
class Roc < Formula
  desc "Fast, friendly, functional programming language"
  homepage "https://www.roc-lang.org"
  version "2026-10-29-a0a9fc2"
  license "UPL-1.0"

  uses_from_macos "expect" => :test

  on_macos do
    # macOS 15 is the oldest version Roc is tested on.
    depends_on macos: :sequoia

    on_arm do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-10-29-a0a9fc2/roc_nightly-macos_apple_silicon-2026-10-29-a0a9fc2.tar.gz"
      sha256 "4c25207e3c1d8db80b23c27ca873431fa6d279670a96614dd0db3483ff2ef65c"
    end
    on_intel do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-10-29-a0a9fc2/roc_nightly-macos_x86_64-2026-10-29-a0a9fc2.tar.gz"
      sha256 "928a8ee347b19c320f70a3434dd341487869a9e73a8e8a0c87ec3da37a57e991"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-10-29-a0a9fc2/roc_nightly-linux_arm64-2026-10-29-a0a9fc2.tar.gz"
      sha256 "2d4c11cc5d258325f5f3424513dc5fa944bcee6bc7a4d3b78889e4dbacc4b268"
    end
    on_intel do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-10-29-a0a9fc2/roc_nightly-linux_x86_64-2026-10-29-a0a9fc2.tar.gz"
      sha256 "149022295109108d4bb373e6bf6c38affdcd3b6be2f22deae05aec15381e47f4"
    end
  end

  # The examples revision that roc-lang.org's examples.json pins; `brew test` runs its CI script
  # on the examples that pin this formula's Roc version.
  resource "examples" do
    url "https://github.com/roc-lang/examples/archive/baa8add8cc5bdf8d86f4dcf93926a4043da3eb48.tar.gz"
    sha256 "1d5518789ad180a40e22f0053449572e23fa8ef65ebbcfc8389cada59fe1fa7b"
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
