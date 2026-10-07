# Interim formula: installs prebuilt binaries from roc-lang/nightlies until Roc has
# a stable release that can go to homebrew-core. Kept in sync with the release in
# roc-lang.org's install_roc.sh by .github/workflows/update.yml.
class Roc < Formula
  desc "Fast, friendly, functional programming language"
  homepage "https://www.roc-lang.org"
  version "2026-09-18-1d982dc"
  license "UPL-1.0"

  uses_from_macos "expect" => :test

  on_macos do
    # macOS 15 is the oldest version Roc is tested on.
    depends_on macos: :sequoia

    on_arm do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-09-18-1d982dc/roc_nightly-macos_apple_silicon-2026-09-18-1d982dc.tar.gz"
      sha256 "3e27f5020ab8ef848b6facf5ed213c464795695f589f3341263823944cfe4cff"
    end
    on_intel do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-09-18-1d982dc/roc_nightly-macos_x86_64-2026-09-18-1d982dc.tar.gz"
      sha256 "6479edcf15cae24c31242f32477dbfff17fbee836927e0f6128eeb3993286495"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-09-18-1d982dc/roc_nightly-linux_arm64-2026-09-18-1d982dc.tar.gz"
      sha256 "bd0f35d221031e289fafa0a1f24d39e18e6524c70d8b1ab926949b636bf51151"
    end
    on_intel do
      url "https://github.com/roc-lang/nightlies/releases/download/nightly-2026-09-18-1d982dc/roc_nightly-linux_x86_64-2026-09-18-1d982dc.tar.gz"
      sha256 "503e6e573495674ddfe57e3db5390c403afa3764a7bb2b87c567f391beda5df5"
    end
  end

  # The examples revision that roc-lang.org's examples.json pins; `brew test` runs its CI script.
  resource "examples" do
    url "https://github.com/roc-lang/examples/archive/c176d73044107111d8cd931839b7a3659f924736.tar.gz"
    sha256 "f12a17a9a243a87ff83aa6ae8cacebd12dd66aff178c34d6aabfc2c90feeb8fa"
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
    ENV["ROC"] = bin/"roc"
    system "bash", "ci_scripts/all_tests.sh"
  end
end
