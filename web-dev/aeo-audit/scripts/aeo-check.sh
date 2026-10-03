#!/usr/bin/env bash
# AEO quick check against a deployed site.
# Usage: aeo-check.sh https://example.com
# Exit code = number of failed standard checks. Opt-in conventions are reported, never counted.

if [ $# -lt 1 ]; then
  echo "usage: $0 BASE_URL   (the deployed URL, not localhost)" >&2
  exit 2
fi

BASE="${1%/}"
FAIL=0

pass() { echo "  ✓ $1"; }
fail() { echo "  ✗ $1"; FAIL=$((FAIL + 1)); }
info() { echo "  · $1"; }

fetch() { curl -sfL --max-time 20 "$@"; }

echo "=== AEO quick check: $BASE ==="

echo ""
echo "--- Discovery (standard) ---"

if fetch "$BASE/sitemap.xml" | grep -qE '<(urlset|sitemapindex)'; then
  pass "sitemap.xml (urlset or sitemapindex)"
else
  fail "sitemap.xml missing or not a sitemap"
fi

ROBOTS=$(fetch "$BASE/robots.txt")
if [ -n "$ROBOTS" ]; then
  pass "robots.txt"
  if printf '%s\n' "$ROBOTS" | grep -qi '^sitemap:'; then
    pass "robots.txt has Sitemap: line"
  else
    fail "robots.txt has no Sitemap: line"
  fi
else
  fail "robots.txt missing"
fi

echo ""
echo "--- llms.txt (standard) ---"

if fetch "$BASE/llms.txt" | head -1 | grep -q '^# '; then
  pass "llms.txt starts with an H1"
else
  fail "llms.txt missing or does not start with '# '"
fi

echo ""
echo "--- Raw HTML (standard) ---"

HTML=$(fetch "$BASE/")
if printf '%s' "$HTML" | grep -q '<h1'; then
  pass "h1 in server-rendered HTML"
else
  fail "no h1 in server-rendered HTML"
fi

if printf '%s' "$HTML" | grep -q 'application/ld+json'; then
  pass "JSON-LD present"
else
  fail "JSON-LD missing"
fi

for tag in 'og:title' 'og:description' 'og:image'; do
  if printf '%s' "$HTML" | grep -q "property=\"$tag\""; then
    pass "$tag"
  else
    fail "$tag missing"
  fi
done

echo ""
echo "--- Opt-in conventions (informational) ---"

LINK=$(curl -sIL --max-time 20 "$BASE/" | grep -i '^link:')
[ -n "$LINK" ] && info "Link header: $LINK" || info "no Link header"

SIZE=$(fetch "$BASE/llms-full.txt" | wc -c | tr -d ' ')
[ "${SIZE:-0}" -gt 0 ] && info "llms-full.txt ($SIZE bytes)" || info "no llms-full.txt"

fetch "$BASE/index.md" | head -1 | grep -q '^# ' && info "index.md present" || info "no index.md"
fetch "$BASE/agent" | jq -e . >/dev/null 2>&1 && info "/agent returns JSON" || info "no /agent JSON"
fetch "$BASE/.well-known/agent-card.json" | jq -e . >/dev/null 2>&1 && info "A2A agent card present" || info "no A2A agent card"

echo ""
if [ "$FAIL" -eq 0 ]; then
  echo "=== ALL STANDARD CHECKS PASSED ==="
else
  echo "=== $FAIL STANDARD CHECK(S) FAILED ==="
fi
exit "$FAIL"
