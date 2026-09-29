# homebrew-roc

Homebrew tap for [Roc](https://www.roc-lang.org).

```sh
brew install roc-lang/roc/roc
```

This installs a prebuilt [Roc nightly](https://github.com/roc-lang/nightlies/releases) for macOS 15+ (Apple silicon and Intel) or Linux (x86_64 and arm64).
`brew upgrade roc` moves you to the newest nightly the tap has picked up.

This tap is an interim solution until Roc has a stable release that can go into homebrew-core.

## How the formula is updated

[update.yml](.github/workflows/update.yml) checks for a new nightly every three hours.
It only commits the new version to `Formula/roc.rb` once `brew install` and `brew test` pass on all four platforms, so a nightly that is missing a platform or fails to install is skipped.

To pin a specific nightly, run that workflow manually with a `tag`, or run this locally (needs `gh`):

```sh
scripts/update-formula.sh nightly-2026-09-23-c7852fd
```
