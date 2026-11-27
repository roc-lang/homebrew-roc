# Interim formula: installs prebuilt binaries from roc-lang/roc releases until Roc has
# a stable release that can go to homebrew-core. Kept in sync with the release in
# roc-lang.org's install_roc.sh by .github/workflows/update.yml.
class Roc < Formula
  desc "Fast, friendly, functional programming language"
  homepage "https://www.roc-lang.org"
  license "UPL-1.0"
  # Nightly versions like 2026-11-15-f25da45 would otherwise sort above 0.1.0_RC1.
  version_scheme 1

  uses_from_macos "expect" => :test

  on_macos do
    # macOS 15 is the oldest version Roc is tested on.
    depends_on macos: :sequoia

    on_arm do
      url "https://github.com/roc-lang/roc/releases/download/0.1.0/roc-macos_apple_silicon-0.1.0.tar.gz"
      sha256 "6143ed7eb2b5bebaefa6c4b48f97dede0e97644d4fde076b6258076cbecfc504"
    end
    on_intel do
      url "https://github.com/roc-lang/roc/releases/download/0.1.0/roc-macos_x86_64-0.1.0.tar.gz"
      sha256 "12ac24a0eea147134d74b060746388e7f1981db996c2fbeb47c21f2fafd9ca45"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/roc-lang/roc/releases/download/0.1.0/roc-linux_arm64-0.1.0.tar.gz"
      sha256 "635c38a0128fdc77cfe4f225ecd2e213e24f04fe65e3ccbafea5ca20e041d01f"
    end
    on_intel do
      url "https://github.com/roc-lang/roc/releases/download/0.1.0/roc-linux_x86_64-0.1.0.tar.gz"
      sha256 "40f3e43f762dbf18597201739a6f645badcd05edbf9ea353805c5453a9336cfd"
    end
  end

  # `brew test` runs this revision's CI script on the examples that pin this formula's Roc version.
  # Follows roc-lang.org's examples.json once its examples pin this version.
  resource "examples" do
    url "https://github.com/roc-lang/examples/archive/96a3521dc8cc41abd47e8f3d79942062f8a8f261.tar.gz"
    sha256 "eae6a55abade2f7911dad0c68631121eda4b4ceb13b69d224c5a59cb8b364666"
  end

  def install
    # roc links against the `darwin` sysroot next to its symlink-resolved path, so keep them together.
    libexec.install "roc"
    libexec.install "darwin" if OS.mac?
    bin.install_symlink libexec/"roc"
    prefix.install "legal_details"
  end

  test do
    assert_equal "Roc compiler version #{version}", shell_output("#{bin}/roc version").strip

    resource("examples").stage testpath
    # Each example pins its Roc version in its header; only those pinning this release must pass with it.
    # Headers spell the release 0.1.0_RC1 as 0.1.0-RC1.
    release = version.to_s.tr("_", "-")
    pin = "roc: \"#{release}\""
    # Examples can lag behind a release, so pins of its release candidates count as pinning it.
    roc_files = (testpath/"examples").glob("**/*.roc")
    inreplace roc_files, /roc: "#{Regexp.escape(release)}[-_]RC\d+"/, pin, audit_result: false
    examples = (testpath/"examples").children.select do |dir|
      dir.glob("**/*.roc").any? { |file| file.read.include?(pin) }
    end
    # ElmWebApp needs Firefox, which cannot start in Homebrew's macOS test sandbox.
    examples.reject! { |dir| dir.basename.to_s == "ElmWebApp" }
    refute_empty examples, "no example pins #{pin}"
    ENV["ROC"] = bin/"roc"
    system "bash", "ci_scripts/all_tests.sh", *examples.map { |dir| dir.basename.to_s }
  end
end
