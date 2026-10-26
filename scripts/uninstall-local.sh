#!/usr/bin/env bash
# Uninstall agent-skills from IDE and CLI skill directories.
# Supports full uninstallation or selective removal of specific skills.
#
# Usage:
#   ./scripts/uninstall-local.sh --list
#   ./scripts/uninstall-local.sh --all
#   ./scripts/uninstall-local.sh --only cursor,claude
#   ./scripts/uninstall-local.sh --skills s-perf,s-debug
#   ./scripts/uninstall-local.sh --scope user|project
#   ./scripts/uninstall-local.sh --keep-aliases
set -euo pipefail

MARKER_SKILL="using-agent-skills"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_ROOT="$REPO_ROOT/skills"
REFERENCES_ROOT="$REPO_ROOT/references"

IDS=(cursor claude codex gemini antigravity windsurf opencode copilot copilot-cli kiro commandcode)
LABELS=(
  "Cursor"
  "Claude Code"
  "Codex"
  "Gemini CLI"
  "Antigravity CLI"
  "Windsurf"
  "OpenCode"
  "GitHub Copilot"
  "Copilot CLI"
  "Kiro"
  "Command Code"
)

LIST_ONLY=0
UNINSTALL_ALL=0
ONLY_RAW=""
SKILLS_RAW=""
SCOPE=""
PROJECT=""
KEEP_ALIASES=0

usage() {
  cat <<'EOF'
uninstall-local.sh — remove agent-skills from detected IDE/CLI folders.

  --list                 Show detection and installed skills, then exit
  --all                  Uninstall from every detected target (no menu)
  --only id[,id...]      Uninstall only from these ids
  --skills s1[,s2...]    Selectively remove only specified skills (e.g. s-perf,s-debug)
  --scope user|project   user = home config (default); project = one repo
  --project <path>       Project root for --scope project
  --keep-aliases         Keep /s-* slash command aliases (do not remove them)
  --help                 Show this help

Ids: cursor, claude, codex, gemini, antigravity, windsurf, opencode,
     copilot, copilot-cli, kiro, commandcode
EOF
}

have_command() {
  command -v "$1" >/dev/null 2>&1
}

path_exists() {
  [[ -n "${1:-}" && -e "$1" ]]
}

index_of() {
  local id="$1" i
  for i in "${!IDS[@]}"; do
    if [[ "${IDS[$i]}" == "$id" ]]; then
      echo "$i"
      return 0
    fi
  done
  return 1
}

user_skills_for() {
  case "$1" in
    cursor) echo "$HOME/.cursor/skills" ;;
    claude) echo "$HOME/.claude/skills" ;;
    codex) echo "$HOME/.codex/skills" ;;
    gemini) echo "$HOME/.gemini/skills" ;;
    antigravity) echo "$HOME/.gemini/config/plugins/agent-skills/skills" ;;
    windsurf) echo "$HOME/.codeium/windsurf/skills" ;;
    opencode) echo "$HOME/.config/opencode/skills" ;;
    copilot) echo "$HOME/.agents/skills" ;;
    copilot-cli) echo "$HOME/.copilot/skills" ;;
    kiro) echo "$HOME/.kiro/skills" ;;
    commandcode) echo "$HOME/.commandcode/skills" ;;
    *) return 1 ;;
  esac
}

project_skills_for() {
  case "$1" in
    cursor) echo ".cursor/skills" ;;
    claude) echo ".claude/skills" ;;
    codex) echo ".agents/skills" ;;
    gemini) echo ".gemini/skills" ;;
    antigravity) echo ".agent/skills" ;;
    windsurf) echo ".windsurf/skills" ;;
    opencode) echo ".opencode/skills" ;;
    copilot) echo ".github/skills" ;;
    copilot-cli) echo ".github/skills" ;;
    kiro) echo ".kiro/skills" ;;
    commandcode) echo ".commandcode/skills" ;;
    *) return 1 ;;
  esac
}

destination_for() {
  local id="$1"
  if [[ "$SCOPE" == "project" ]]; then
    echo "$PROJECT/$(project_skills_for "$id")"
  else
    user_skills_for "$id"
  fi
}

installed_skill_count() {
  local dest="$1" count=0 dir
  [[ -d "$dest" ]] || { echo 0; return; }
  for dir in "$dest"/*; do
    [[ -d "$dir" && -f "$dir/SKILL.md" ]] || continue
    count=$((count + 1))
  done
  echo "$count"
}

marker_installed() {
  [[ -f "$1/$MARKER_SKILL/SKILL.md" ]]
}

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
    kiro)
      have_command kiro || path_exists "$HOME/.kiro"
      ;;
    commandcode)
      have_command commandcode || path_exists "$HOME/.commandcode"
      ;;
  esac
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --list) LIST_ONLY=1; shift ;;
    --all) UNINSTALL_ALL=1; shift ;;
    --only) ONLY_RAW="${2:-}"; shift 2 ;;
    --skills) SKILLS_RAW="${2:-}"; shift 2 ;;
    --scope) SCOPE="${2:-}"; shift 2 ;;
    --project) PROJECT="${2:-}"; shift 2 ;;
    --keep-aliases) KEEP_ALIASES=1; shift ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ -n "$PROJECT" || "$SCOPE" == "project" ]]; then
  SCOPE="project"
  if [[ -z "$PROJECT" ]]; then
    PROJECT="$(pwd)"
  fi
  PROJECT="$(cd "$PROJECT" && pwd)"
else
  SCOPE="${SCOPE:-user}"
fi

# Build array of target skills if selective
SPECIFIC_SKILLS=()
if [[ -n "$SKILLS_RAW" ]]; then
  IFS=',' read -ra S_ARR <<< "$SKILLS_RAW"
  for s in "${S_ARR[@]}"; do
    s="$(echo "$s" | xargs)"
    [[ -n "$s" ]] && SPECIFIC_SKILLS+=("$s")
  done
fi

DESTS=()
FOUND=()
INSTALLED=()
for id in "${IDS[@]}"; do
  dest="$(destination_for "$id")"
  DESTS+=("$dest")
  if detect_target "$id"; then
    FOUND+=(1)
  else
    FOUND+=(0)
  fi
  if [[ -d "$dest" ]]; then
    INSTALLED+=($(installed_skill_count "$dest"))
  else
    INSTALLED+=(0)
  fi
done

if [[ "$LIST_ONLY" -eq 1 ]]; then
  echo "Scope: $SCOPE"
  [[ "$SCOPE" == "project" ]] && echo "Project: $PROJECT"
  echo
  printf "%-4s %-16s %-10s %-12s %s\n" "#" "Tool" "Detected" "Installed" "Destination"
  printf "%-4s %-16s %-10s %-12s %s\n" "--" "----------------" "----------" "------------" "----------------------------------------"
  for i in "${!IDS[@]}"; do
    det="no"
    [[ "${FOUND[$i]}" -eq 1 ]] && det="yes"
    printf "%-4d %-16s %-10s %-12s %s\n" "$((i+1))" "${LABELS[$i]}" "$det" "${INSTALLED[$i]} skills" "${DESTS[$i]}"
  done
  exit 0
fi

selected=()
if [[ -n "$ONLY_RAW" ]]; then
  IFS=',' read -ra ADDR <<< "$ONLY_RAW"
  for token in "${ADDR[@]}"; do
    token="$(echo "$token" | xargs | tr '[:upper:]' '[:lower:]')"
    [[ -z "$token" ]] && continue
    if ! index_of "$token" >/dev/null; then
      echo "Unknown id: $token" >&2
      exit 1
    fi
    selected+=("$token")
  done
elif [[ "$UNINSTALL_ALL" -eq 1 ]]; then
  for i in "${!IDS[@]}"; do
    if [[ "${FOUND[$i]}" -eq 1 || "${INSTALLED[$i]}" -gt 0 ]]; then
      selected+=("${IDS[$i]}")
    fi
  done
else
  # Interactive mode
  echo "Scope: $SCOPE"
  [[ "$SCOPE" == "project" ]] && echo "Project: $PROJECT"
  echo
  printf "%-4s %-16s %-10s %-12s %s\n" "#" "Tool" "Detected" "Installed" "Destination"
  printf "%-4s %-16s %-10s %-12s %s\n" "--" "----------------" "----------" "------------" "----------------------------------------"
  for i in "${!IDS[@]}"; do
    det="no"
    [[ "${FOUND[$i]}" -eq 1 ]] && det="yes"
    printf "%-4d %-16s %-10s %-12s %s\n" "$((i+1))" "${LABELS[$i]}" "$det" "${INSTALLED[$i]} skills" "${DESTS[$i]}"
  done
  echo
  echo "Select targets to uninstall:"
  echo "  Enter  uninstall from every target that currently has installed skills"
  echo "  a      uninstall from every detected target"
  echo "  1,3,5  or 1-4 (specific row numbers)"
  echo "  q      quit"
  read -r -p "Target(s) [Enter]: " choice
  choice="$(printf '%s' "$choice" | tr -d ' ')"

  if [[ "$choice" == "q" || "$choice" == "quit" ]]; then
    echo "Cancelled."
    exit 0
  elif [[ "$choice" == "a" || "$choice" == "all" ]]; then
    for i in "${!IDS[@]}"; do
      if [[ "${FOUND[$i]}" -eq 1 ]]; then
        selected+=("${IDS[$i]}")
      fi
    done
  elif [[ -z "$choice" ]]; then
    for i in "${!IDS[@]}"; do
      if [[ "${INSTALLED[$i]}" -gt 0 ]]; then
        selected+=("${IDS[$i]}")
      fi
    done
  else
    IFS=',' read -ra TOKENS <<< "$choice"
    for token in "${TOKENS[@]}"; do
      if [[ "$token" =~ ^([0-9]+)-([0-9]+)$ ]]; then
        for ((n=${BASH_REMATCH[1]}; n<=${BASH_REMATCH[2]}; n++)); do
          idx=$((n - 1))
          if [[ "$idx" -ge 0 && "$idx" -lt ${#IDS[@]} ]]; then
            selected+=("${IDS[$idx]}")
          fi
        done
      elif [[ "$token" =~ ^[0-9]+$ ]]; then
        idx=$((token - 1))
        if [[ "$idx" -ge 0 && "$idx" -lt ${#IDS[@]} ]]; then
          selected+=("${IDS[$idx]}")
        fi
      fi
    done
  fi
fi

if [[ ${#selected[@]} -eq 0 ]]; then
  echo "No targets selected or no installed skills found."
  exit 0
fi

# Unique targets preserving order
unique=()
for id in "${selected[@]}"; do
  skip=0
  for seen in "${unique[@]:-}"; do
    [[ "$seen" == "$id" ]] && skip=1
  done
  [[ "$skip" -eq 1 ]] && continue
  unique+=("$id")
done

uninstall_from_dir() {
  local dest="$1"
  local removed=0
  [[ -d "$dest" ]] || { echo 0; return; }

  if [[ ${#SPECIFIC_SKILLS[@]} -gt 0 ]]; then
    # Selective uninstallation
    for skill in "${SPECIFIC_SKILLS[@]}"; do
      if [[ -d "$dest/$skill" ]]; then
        rm -rf "$dest/$skill"
        removed=$((removed + 1))
      fi
    done
  else
    # Full uninstallation of all agent-skills
    # 1. Enumerate known repo skills
    if [[ -d "$SKILLS_ROOT" ]]; then
      for dir in "$SKILLS_ROOT"/*; do
        [[ -d "$dir" && -f "$dir/SKILL.md" ]] || continue
        name="$(basename "$dir")"
        if [[ -d "$dest/$name" ]]; then
          rm -rf "$dest/$name"
          removed=$((removed + 1))
        fi
      done
    fi

    # 2. Clean install marker
    rm -f "$dest/.agent-skills-install.json"

    # 3. Clean references if present
    local ref_dir="$(dirname "$dest")/references"
    if [[ -d "$ref_dir" ]]; then
      rm -rf "$ref_dir"
    fi

    # 4. Clean empty destination directory
    rmdir "$dest" 2>/dev/null || true
  fi

  echo "$removed"
}

uninstall_plugin() {
  local id="$1"
  case "$id" in
    antigravity)
      if have_command agy; then
        agy plugin uninstall agent-skills >/dev/null 2>&1 || true
      fi
      ;;
    claude)
      if have_command claude; then
        claude plugin uninstall agent-skills@addy-agent-skills >/dev/null 2>&1 || true
      fi
      ;;
    codex)
      if have_command codex; then
        codex plugin remove agent-skills@agent-skills >/dev/null 2>&1 || true
      fi
      ;;
    copilot-cli)
      if have_command copilot; then
        copilot plugin uninstall agent-skills@addy-agent-skills -y >/dev/null 2>&1 || true
      fi
      ;;
  esac
}

echo "=========================================================="
if [[ ${#SPECIFIC_SKILLS[@]} -gt 0 ]]; then
  echo "Selectively Uninstalling Skill(s): ${SPECIFIC_SKILLS[*]}"
else
  echo "Uninstalling All Agent Skills"
fi
echo "Scope:   $SCOPE"
[[ "$SCOPE" == "project" ]] && echo "Project: $PROJECT"
echo "Targets: ${unique[*]}"
echo "=========================================================="
echo

for id in "${unique[@]}"; do
  idx="$(index_of "$id")"
  dest="${DESTS[$idx]}"
  echo "Processing ${LABELS[$idx]} ($id)..."
  
  if [[ ${#SPECIFIC_SKILLS[@]} -eq 0 ]]; then
    uninstall_plugin "$id"
  fi

  removed="$(uninstall_from_dir "$dest")"
  echo "  ✓ Removed $removed skill directory(ies) from $dest"
  
  # For Antigravity, also check global ~/.gemini/config/skills if user scope
  if [[ "$id" == "antigravity" && "$SCOPE" == "user" ]]; then
    extra_dest="$HOME/.gemini/config/skills"
    if [[ -d "$extra_dest" ]]; then
      extra_removed="$(uninstall_from_dir "$extra_dest")"
      [[ "$extra_removed" -gt 0 ]] && echo "  ✓ Removed $extra_removed skill(s) from $extra_dest"
    fi
  fi
done

# Cleanup slash command aliases unless --keep-aliases
if [[ "$KEEP_ALIASES" -eq 0 && ${#SPECIFIC_SKILLS[@]} -eq 0 && -f "$REPO_ROOT/scripts/install-aliases.sh" ]]; then
  alias_args=(--uninstall)
  [[ "$SCOPE" == "project" ]] && alias_args+=(--scope project --project "$PROJECT")
  target_list="$(IFS=','; echo "${unique[*]}")"
  alias_args+=(--only "$target_list")
  echo
  "$REPO_ROOT/scripts/install-aliases.sh" "${alias_args[@]}"
fi

echo
echo "Uninstallation complete for ${#unique[@]} target(s)."
