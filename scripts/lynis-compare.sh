#!/usr/bin/env bash
# Usage: lynis-compare.sh report1.dat [report2.dat ...]
set -euo pipefail
for f in "$@"; do
  echo "== $f"
  grep -E '^hardening_index=' "$f"
  echo "warnings:    $(grep -c '^warning\[\]=' "$f")"
  echo "suggestions: $(grep -c '^suggestion\[\]=' "$f")"
done
