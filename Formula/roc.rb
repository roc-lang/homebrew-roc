# Interim formula: installs prebuilt binaries from roc-lang/nightlies until Roc has
# a stable release that can go to homebrew-core. Kept in sync with the release in
# roc-lang.org's install_roc.sh by .github/workflows/update.yml.
class Roc < Formula
  desc "Fast, friendly, functional programming language"
  homepage "https://www.roc-lang.org"
  version "2026-11-03-34bd006"
  license "UPL-1.0"

  uses_from_macos "expect" => :test

  on_macos do
    # macOS 15 is the oldest version Roc is tested on.
    depends_on macos: :sequoia

    on_arm do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-11-03-34bd006/roc_nightly-macos_apple_silicon-2026-11-03-34bd006.tar.gz"
      sha256 "4fb663f541cda0bb4fa6556c70caadd08fc306f52aa9a228822e45254e157c10"
    end
    on_intel do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-11-03-34bd006/roc_nightly-macos_x86_64-2026-11-03-34bd006.tar.gz"
      sha256 "ca27bab3ab4af86a959dac1499f776794f9985972095891838f64aa71dbcc5c8"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-11-03-34bd006/roc_nightly-linux_arm64-2026-11-03-34bd006.tar.gz"
      sha256 "6d2fb75f2cf3dc3f3013e2795df86d75872cceaa9f6e5a3038d49115f4a096f1"
    end
    on_intel do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-11-03-34bd006/roc_nightly-linux_x86_64-2026-11-03-34bd006.tar.gz"
      sha256 "d5c769579edd8e26114b5a89c16e7e074295649a6721a620c98a090eb2bb62c7"
    end
  end

  # The examples revision that roc-lang.org's examples.json pins; `brew test` runs its CI script
  # on the examples that pin this formula's Roc version.
  resource "examples" do
    url "https://github.com/roc-lang/examples/archive/7bc214b08ca6439c083e873b553a90011944d514.tar.gz"
    sha256 "c085ab9751b9e8fe86336962d4dd119a0d8644c7c9e1db8a9c58c594d86e0ace"
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
