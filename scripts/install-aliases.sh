#!/usr/bin/env bash
# install-aliases.sh — installs short /s-* lifecycle skill wrappers into IDE/CLI skill directories.
# Makes /s-spec, /s-plan, /s-build, /s-test, /s-review, /s-simplify, /s-ship, /s-guard, /s-perf
# appear as slash commands across Cursor, Antigravity, OpenCode, Codex, Windsurf, Copilot, etc.
#
# Usage:
#   ./scripts/install-aliases.sh              # Interactive install for detected IDEs
#   ./scripts/install-aliases.sh --all        # Install to all detected IDEs
#   ./scripts/install-aliases.sh --only cursor,antigravity
#   ./scripts/install-aliases.sh --scope project --project /path/to/repo
#   ./scripts/install-aliases.sh --list
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
COMMANDS_DIR="$REPO_ROOT/.claude/commands"

IDS=(cursor antigravity claude codex gemini windsurf opencode copilot copilot-cli)
LABELS=(
  "Cursor"
  "Antigravity"
  "Claude Code"
  "Codex"
  "Gemini CLI"
  "Windsurf"
  "OpenCode"
  "GitHub Copilot"
  "Copilot CLI"
)

LIST_ONLY=0
INSTALL_ALL=0
ONLY_RAW=""
SCOPE="user"
PROJECT=""

usage() {
  cat <<'EOF'
install-aliases.sh — install short /s-* slash commands into detected IDE/CLI skill directories.

  --list                 Show detection and destinations, then exit
  --all                  Install every detected target (no prompt)
  --only id[,id...]      Install specific targets (e.g. --only cursor,antigravity)
  --scope user|project   user = home config (default); project = one repo
  --project <path>       Project root for --scope project
  --help                 Show this help

Supported IDEs: cursor, antigravity, claude, codex, gemini, windsurf, opencode, copilot, copilot-cli
EOF
}

have_command() {
  command -v "$1" >/dev/null 2>&1
}

path_exists() {
  [[ -n "${1:-}" && -e "$1" ]]
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --list) LIST_ONLY=1; shift ;;
    --all) INSTALL_ALL=1; shift ;;
    --only) ONLY_RAW="$2"; shift 2 ;;
    --scope) SCOPE="$2"; shift 2 ;;
    --project) PROJECT="$2"; shift 2 ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ "$SCOPE" == "project" ]]; then
  if [[ -z "$PROJECT" ]]; then
    PROJECT="$PWD"
  fi
  PROJECT="$(cd "$PROJECT" && pwd)"
fi

detect_target() {
  local id="$1" local_app="${LOCALAPPDATA:-}"
  case "$id" in
    cursor)
      have_command cursor || path_exists "$local_app/Programs/cursor/Cursor.exe" || path_exists "$HOME/.cursor"
      ;;
    claude)
      have_command claude || path_exists "$HOME/.claude"
      ;;
    codex)
      have_command codex || path_exists "$HOME/.codex"
      ;;
    gemini)
      have_command gemini || path_exists "$HOME/.gemini"
      ;;
    antigravity)
      have_command agy || path_exists "$local_app/Programs/Antigravity/Antigravity.exe" || path_exists "$HOME/.gemini/config" || path_exists "$HOME/.gemini/antigravity-cli"
      ;;
    windsurf)
      have_command windsurf || path_exists "$local_app/Programs/Windsurf/Windsurf.exe" || path_exists "$HOME/.codeium/windsurf"
      ;;
    opencode)
      have_command opencode || path_exists "$HOME/.config/opencode"
      ;;
    copilot)
      path_exists "$HOME/.agents/skills" || (have_command code && code --list-extensions 2>/dev/null | grep -qi '^github\.copilot$')
      ;;
    copilot-cli)
      have_command copilot || path_exists "$HOME/.copilot"
      ;;
    *) return 1 ;;
  esac
}

user_destinations_for() {
  local id="$1"
  case "$id" in
    cursor) echo "$HOME/.cursor/skills" ;;
    antigravity)
      # Antigravity supports global skills in ~/.gemini/config/skills and in plugins
      echo "$HOME/.gemini/config/skills"
      echo "$HOME/.gemini/config/plugins/agent-skills/skills"
      ;;
    claude) echo "$HOME/.claude/skills" ;;
    codex) echo "$HOME/.codex/skills" ;;
    gemini) echo "$HOME/.gemini/skills" ;;
    windsurf) echo "$HOME/.codeium/windsurf/skills" ;;
    opencode) echo "$HOME/.config/opencode/skills" ;;
    copilot) echo "$HOME/.agents/skills" ;;
    copilot-cli) echo "$HOME/.copilot/skills" ;;
    *) return 1 ;;
  esac
}

project_destinations_for() {
  local id="$1"
  case "$id" in
    cursor) echo "$PROJECT/.cursor/skills" ;;
    antigravity) echo "$PROJECT/.agents/skills" ;;
    claude) echo "$PROJECT/.claude/skills" ;;
    codex) echo "$PROJECT/.agents/skills" ;;
    gemini) echo "$PROJECT/.gemini/skills" ;;
    windsurf) echo "$PROJECT/.windsurf/skills" ;;
    opencode) echo "$PROJECT/.opencode/skills" ;;
    copilot)
      echo "$PROJECT/.github/skills"
      echo "$PROJECT/.github/prompts"
      ;;
    copilot-cli) echo "$PROJECT/.github/skills" ;;
    *) return 1 ;;
  esac
}

# The 9 slash commands to generate
ALIAS_COMMANDS=(s-spec s-plan s-build s-test s-review s-simplify s-ship s-guard s-perf)

create_alias_skill() {
  local cmd_name="$1"
  local dest_dir="$2"
  local cmd_file="$COMMANDS_DIR/$cmd_name.md"
  
  if [[ ! -f "$cmd_file" ]]; then
    echo "Warning: command source $cmd_file not found." >&2
    return 1
  fi

  local target_skill_dir="$dest_dir/$cmd_name"
  mkdir -p "$target_skill_dir"

  # Extract description from frontmatter
  local desc
  desc="$(sed -n '/^description:[[:space:]]*/{s/^description:[[:space:]]*//;p;q;}' "$cmd_file")"
  if [[ -z "$desc" ]]; then
    desc="Runs the $cmd_name workflow"
  fi

  # Extract body (everything after second ---)
  local body
  body="$(awk 'BEGIN{c=0} /^---$/{c++; next} c>=2{print}' "$cmd_file")"

  # Replace 'agent-skills:' namespace with bare skill names for cross-IDE compatibility
  local clean_body
  clean_body="$(echo "$body" | sed 's/agent-skills://g')"

  cat > "$target_skill_dir/SKILL.md" <<EOF
---
name: $cmd_name
description: $desc
---

# /$cmd_name

$clean_body
EOF
}

create_copilot_prompt() {
  local cmd_name="$1"
  local dest_dir="$2"
  local cmd_file="$COMMANDS_DIR/$cmd_name.md"
  
  [[ -f "$cmd_file" ]] || return 1
  mkdir -p "$dest_dir"

  local desc body clean_body
  desc="$(sed -n '/^description:[[:space:]]*/{s/^description:[[:space:]]*//;p;q;}' "$cmd_file")"
  body="$(awk 'BEGIN{c=0} /^---$/{c++; next} c>=2{print}' "$cmd_file")"
  clean_body="$(echo "$body" | sed 's/agent-skills://g')"

  cat > "$dest_dir/$cmd_name.prompt.md" <<EOF
---
description: $desc
---

$clean_body
EOF
}

install_to_destination() {
  local dest="$1"
  mkdir -p "$dest"
  local cmd
  for cmd in "${ALIAS_COMMANDS[@]}"; do
    if [[ "$dest" == *"/prompts" ]]; then
      create_copilot_prompt "$cmd" "$dest"
    else
      create_alias_skill "$cmd" "$dest"
    fi
  done
}

# Determine selected targets
SELECTED=()
if [[ -n "$ONLY_RAW" ]]; then
  IFS=',' read -ra ADDR <<< "$ONLY_RAW"
  for target in "${ADDR[@]}"; do
    target="$(echo "$target" | xargs)"
    SELECTED+=("$target")
  done
elif [[ "$INSTALL_ALL" -eq 1 ]]; then
  for id in "${IDS[@]}"; do
    if detect_target "$id"; then
      SELECTED+=("$id")
    fi
  done
else
  # Default when running interactively without flags: select all detected targets
  for id in "${IDS[@]}"; do
    if detect_target "$id"; then
      SELECTED+=("$id")
    fi
  done
fi

if [[ "$LIST_ONLY" -eq 1 ]]; then
  echo "Target slash command wrappers (${#ALIAS_COMMANDS[@]}): ${ALIAS_COMMANDS[*]}"
  echo "Scope: $SCOPE"
  [[ "$SCOPE" == "project" ]] && echo "Project: $PROJECT"
  echo
  printf "%-4s %-14s %-10s %s\n" "#" "ID" "Detected" "Destination(s)"
  printf "%-4s %-14s %-10s %s\n" "--" "--------------" "----------" "----------------------------------"
  i=1
  for id in "${IDS[@]}"; do
    detected="no"
    if detect_target "$id"; then detected="yes"; fi
    if [[ "$SCOPE" == "project" ]]; then
      dests="$(project_destinations_for "$id" | tr '\n' ' ')"
    else
      dests="$(user_destinations_for "$id" | tr '\n' ' ')"
    fi
    printf "%-4d %-14s %-10s %s\n" "$i" "$id" "$detected" "$dests"
    i=$((i+1))
  done
  exit 0
fi

echo "=========================================================="
echo "Installing /s-* Slash Command Wrappers"
echo "Commands: ${ALIAS_COMMANDS[*]}"
echo "Scope:    $SCOPE"
[[ "$SCOPE" == "project" ]] && echo "Project:  $PROJECT"
echo "=========================================================="
echo

for id in "${SELECTED[@]}"; do
  echo "Target: $id"
  if [[ "$SCOPE" == "project" ]]; then
    while IFS= read -r dest; do
      [[ -n "$dest" ]] || continue
      install_to_destination "$dest"
      echo "  ✓ Installed 9 /s-* commands -> $dest"
    done < <(project_destinations_for "$id")
  else
    while IFS= read -r dest; do
      [[ -n "$dest" ]] || continue
      install_to_destination "$dest"
      echo "  ✓ Installed 9 /s-* commands -> $dest"
    done < <(user_destinations_for "$id")
  fi
done

echo
echo "Done! The following slash commands are now registered in your IDEs:"
for cmd in "${ALIAS_COMMANDS[@]}"; do
  echo "  /$cmd"
done
echo
echo "Note: If an IDE is currently open, open a new chat window or reload the window to refresh the slash command catalog."
