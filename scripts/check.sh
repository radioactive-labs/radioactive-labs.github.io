#!/usr/bin/env bash
# Guardrails for the Radioactive Labs site. Run before every commit.
set -uo pipefail
cd "$(dirname "$0")/.."

SITE_FILES=(index.html 404.html robots.txt sitemap.xml)
fail=0

for f in "${SITE_FILES[@]}"; do
  [ -f "$f" ] || { echo "MISSING FILE: $f"; fail=1; }
done
[ -f index.html ] || { echo "FAILED (no index.html)"; exit 1; }

EXISTING_HTML=()
for f in index.html 404.html; do [ -f "$f" ] && EXISTING_HTML+=("$f"); done

# --- facts that MUST appear ---
require() { grep -qF -- "$1" index.html || { echo "MISSING FACT: $1"; fail=1; }; }
require "hello@fayaworks.com"
require "Fayaworks Technologies Ltd"
require "https://fayaworks.com/"

# --- strings that must NEVER be published ---
# Encoded, not plaintext: this script is served at /scripts/check.sh like any
# other file, so plaintext needles here would be the leak it exists to prevent.
SCANNED=()
for p in "${SITE_FILES[@]}" assets; do [ -e "$p" ] && SCANNED+=("$p"); done
FORBIDDEN_B64=(
  QzAwMTY4MDAxMjU=
  QWR1LUJvYWt5ZQ==
  QmFuZXNlaA==
  RnJvZWxpY2g=
  RGphbWFo
  T3NlaSBZYXc=
  TUFORVQgVklMTEU=
  VFJBQ09BRg==
  U09FIFJFU0lERU5USUFM
  T0JJQklOSQ==
  MDMwMjUwNzM3OA==
  cmFkaW9hY3RpdmVsYWJzLmRldg==
  dGhlZHVtYnRlY2hndXkuY29t
)
for b64 in "${FORBIDDEN_B64[@]}"; do
  needle=$(printf '%s' "$b64" | base64 -d)
  if grep -rqiF -- "$needle" "${SCANNED[@]}" 2>/dev/null; then
    echo "LEAKED (encoded: $b64)"; fail=1
  fi
done

# --- no stray registration documents anywhere in the working tree ---
if find . -maxdepth 2 \( -iname '*.pdf' -o -iname '*.docx' -o -iname '*CLS_Profile*' \) \
     -not -path './.git/*' | grep -q .; then
  echo "REGISTRATION DOCUMENTS PRESENT IN THE WORKING TREE:"
  find . -maxdepth 2 \( -iname '*.pdf' -o -iname '*.docx' -o -iname '*CLS_Profile*' \) -not -path './.git/*'
  echo "  (they must never be committed here)"; fail=1
fi

# --- no external stylesheets or scripts ---
if grep -nE '<script[^>]+src=|rel="stylesheet"|@import' "${EXISTING_HTML[@]}"; then
  echo "EXTERNAL RESOURCE LOADED"; fail=1
fi

if [ $fail -eq 0 ]; then echo "ALL CHECKS PASSED"; else echo "FAILED"; exit 1; fi
