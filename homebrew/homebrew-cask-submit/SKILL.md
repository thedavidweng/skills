---
name: homebrew-cask-submit
description: 'Checks what brew audit misses in a Homebrew cask (URLs, arch, livecheck, zap, regional editions) and prepares the PR. Use when adding or fixing a homebrew-cask cask.'
---

# Homebrew cask submit

Cookbook, Acceptable Casks, and the checkout `CONTRIBUTING.md` already apply. Stop when a check here fails.

**URL.** After stripping the query, 401/403 or `X-Amz-Expires` / `Expires` / `token=` is unusable. URL version = `CFBundleShortVersionString`, including build number and hash. Token is free only if `gh api repos/Homebrew/homebrew-cask/contents/Casks/<letter>/<token>.rb` is 404; then read closed unmerged PRs. `whois` the homepage: ≥30 days. That audit runs only on the official tap. Forges are exempt; switching `homepage` to one waits for the user. Notability is the GitHub repo inside `url` — under 30 forks, 30 watchers, and 75 stars, use the vendor endpoint (`sha256 :no_check`; a 302 to GitHub is fine). A fake version that still returns the latest file means the path ignores `#{version}`. `*-latest` → `sha256 :no_check`. `version :latest` excludes `auto_updates`. Omit `verified:`. Find the feed in `SUFeedURL`, `app.asar`, or the download-button JS, on the vendor host.

**Arch.** `lipo -archs` `Contents/MacOS/` for every build you declare. The filename, and any fat helper or dylib, is not the app's arch. A one-arch feed gets `depends_on arch:` for that arch. Mount with `diskutil image attach --readOnly --mountOptions nobrowse`; unmount with `diskutil unmount` on the volume. On macOS 26+, `hdiutil attach` aborting in autofsck is what brew calls `Download failed`.

**Pair.** Different bundle id, homepage, accounts, and support dir: two casks, two PRs, each from upstream `main`, neither an ancestor of the other. Bare token is the default edition; the suffix is the region. Say why, and link the sibling, in the first paragraph. Same `.app`: `app "Name.app", target: "Name Region.app"`. `conflicts_with` waits until that token is in the official tap.

**livecheck.** Both archs: `#{arch}` in the feed URL and the filename regex, regex passed in as `do |json, regex|`. A version field is read directly (`json["currentRelease"]`). One arch: hardcode it.

**zap.** Paths created by launching that build. On a shared log or crashpad dir, the glob matches this bundle id only (`com.vendor.app-*.log` vs `com.vendor.app.region*.log`). A dir both editions write goes in both. `uninstall quit:` is the bundle id.

**Test.** `brew audit --cask --online --new <user>/<tap>/<token>` — auditing a path is disabled, and the three flags stay together. Tap a repo that contains only this cask. `brew untap --force` on a second full homebrew-cask checkout uninstalls the user's casks. `brew info` `From:` can be a custom remote. Remove temporary `brew trust` entries. Install with `HOMEBREW_NO_INSTALL_FROM_API=1` and `--appdir=/tmp/cask-test`. Run `brew autoremove --dry-run` before uninstall. A `pkill -f` pattern must not appear in that same command.

**PR.** Show the body before `gh pr create` unless the user already said to open it. Squash to one commit per cask, per that checkout's CONTRIBUTING. Checkbox lines stay byte-for-byte, including `<cask>`. Put the reason above the template. This prints `true`:

```sh
gh api repos/Homebrew/.github/contents/.github/scripts/check_template.rb --jq .content | base64 --decode > /tmp/check_template.rb
ruby /tmp/check_template.rb pull-request /tmp/pr_body.md .github/PULL_REQUEST_TEMPLATE.md "<token> <version>" Homebrew/homebrew-cask
```

Name the model on every PR it drafted. A non-maintainer has one open AI-assisted PR; do not relabel a drafted PR as unused AI. The user writes review replies. A template-bot close is fixed by editing the body.
