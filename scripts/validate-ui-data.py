#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
validate-ui-data.py - Root validator for UI/UX datasets and search integrity
"""

import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
SCRIPT_DIR = REPO_ROOT / "skills" / "frontend-ui-engineering" / "scripts"

if not SCRIPT_DIR.exists():
    print(f"Error: UI script directory not found at {SCRIPT_DIR}", file=sys.stderr)
    sys.exit(1)

sys.path.insert(0, str(SCRIPT_DIR))

try:
    from validate_data import main as validate_main
except ImportError as e:
    print(f"Error importing validate_data: {e}", file=sys.stderr)
    sys.exit(1)

if __name__ == "__main__":
    ret = validate_main()
    sys.exit(ret or 0)
