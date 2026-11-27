# homebrew-roc

Homebrew tap for [Roc](https://www.roc-lang.org).

```sh
brew install roc-lang/roc/roc
```

This installs the prebuilt [Roc release](https://github.com/roc-lang/roc/releases) that is pinned in the website's [install_roc.sh](https://github.com/roc-lang/www.roc-lang.org/blob/main/website/public/install_roc.sh), for macOS 15+ (Apple silicon and Intel) or Linux (x86_64 and arm64).

This tap is an interim solution until Roc has a stable release that can go into homebrew-core.

## How the formula is updated

[update.yml](.github/workflows/update.yml) checks every three hours whether `install_roc.sh` points at a different release, and syncs `Formula/roc.rb` with it (version and checksums).
It also takes the [roc-lang/examples](https://github.com/roc-lang/examples) revision from the website's [examples.json](https://github.com/roc-lang/www.roc-lang.org/blob/main/website/examples.json), unless none of its examples pin the new release or one of its release candidates.
`brew test` runs that revision's `ci_scripts/all_tests.sh` against the installed `roc` (needs network), on the examples that pin the formula's release.
Pins of that release's release candidates are first rewritten to the release, since examples can lag behind it.
It leaves out ElmWebApp, which needs Firefox, and Firefox cannot start in Homebrew's macOS test sandbox.
The new version is only committed once `brew install` and `brew test` pass on all four platforms.

To sync manually, run the workflow, or run this locally (needs `gh`):

```sh
scripts/update-formula.sh
```
