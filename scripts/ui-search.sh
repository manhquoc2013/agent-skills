#!/usr/bin/env bash
# ui-search.sh - Workspace shortcut to UI design intelligence search engine
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SEARCH_PY="$REPO_ROOT/skills/frontend-ui-engineering/scripts/search.py"

if [ ! -f "$SEARCH_PY" ]; then
  echo "Error: Search engine not found at $SEARCH_PY" >&2
  exit 1
fi

# Detect python runtime
PYTHON_BIN=""
if command -v python3 >/dev/null 2>&1; then
  PYTHON_BIN="python3"
elif command -v python >/dev/null 2>&1; then
  PYTHON_BIN="python"
elif command -v py >/dev/null 2>&1; then
  PYTHON_BIN="py -3"
else
  echo "Error: Python 3 is required but not installed or not in PATH." >&2
  exit 1
fi

exec $PYTHON_BIN "$SEARCH_PY" "$@"
