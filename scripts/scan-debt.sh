#!/usr/bin/env bash
# scripts/scan-debt.sh
# Shell wrapper around scan-debt.js or fallback to direct git grep

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

if command -v node >/dev/null 2>&1; then
  node "${SCRIPT_DIR}/scan-debt.js" "$@"
else
  echo "# Technical Debt Scanner (fallback mode)"
  git -C "${ROOT_DIR}" grep --no-index --exclude-standard -nE '(#|//|/[*])\s*(shortcut|ponytail):' || {
    echo "No shortcut debt found. Clean ledger."
  }
fi
