#!/usr/bin/env bash
# Install agent-skills from this clone into IDE and CLI skill directories.
# Detects installed tools, then copies the selected targets. No symlinks.
#
#   ./scripts/install-local.sh --list
#   ./scripts/install-local.sh
#   ./scripts/install-local.sh --only cursor,claude --scope user
#   ./scripts/install-local.sh --all --scope project --project /path/to/app
#
# Interactive:
#   Enter  install every detected target that does not yet have skills
#   a      install every detected target
#   1,3,5  or 1-4
#   q      quit
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
INSTALL_ALL=0
ONLY_RAW=""
SCOPE=""
PROJECT=""
NO_ALIASES=0

usage() {
  cat <<'EOF'
install-local.sh — copy this clone's skills into detected IDE/CLI folders.

  --list                 Show detection and destinations, then exit
  --all                  Install every detected target (no menu)
  --only id[,id...]      Install these ids even when not detected
  --scope user|project   user = home config (default); project = one repo
  --project <path>       Project root for --scope project
  --no-aliases           Skip installing short /s-* slash command aliases
  --help                 Show this text

Ids: cursor, claude, codex, gemini, antigravity, windsurf, opencode,
     copilot, copilot-cli, kiro, commandcode
EOF
}

have_command() {
  command -v "$1" >/dev/null 2>&1
}

pack_version() {
  local manifest="$REPO_ROOT/.claude-plugin/plugin.json"
  if [[ -f "$manifest" ]]; then
    sed -n 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$manifest" | head -n 1
    return
  fi
  echo "unknown"
}

source_skill_count() {
  local count=0 dir
  for dir in "$SKILLS_ROOT"/*; do
    [[ -d "$dir" && -f "$dir/SKILL.md" ]] || continue
    count=$((count + 1))
  done
  echo "$count"
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

note_for() {
  case "$1" in
    cursor) echo "Open a new Cursor chat so the skill list reloads." ;;
    claude) echo "Registers this clone with: claude plugin marketplace add <repo> && claude plugin install agent-skills@addy-agent-skills" ;;
    codex) echo "Registers this clone with: codex plugin marketplace add <repo> && codex plugin add agent-skills@agent-skills" ;;
    gemini) echo "Installs with: gemini skills install <repo>/skills" ;;
    antigravity) echo "Installs the whole plugin with: agy plugin install <repo>. Antigravity keeps that plugin global." ;;
    windsurf) echo "This copies skill folders. Windsurf rules files stay untouched." ;;
    opencode) echo "OpenCode reads .opencode/skills and ~/.config/opencode/skills." ;;
    copilot) echo "VS Code Copilot reads .github/skills in the project and ~/.agents/skills for the user." ;;
    copilot-cli) echo "Registers this clone with: copilot plugin marketplace add <repo> && copilot plugin install agent-skills@addy-agent-skills" ;;
    kiro) echo "Kiro loads .kiro/skills (project) and ~/.kiro/skills (global)." ;;
    commandcode) echo "Command Code also supports: cmd skills add <repo> from its own CLI." ;;
  esac
}

path_exists() {
  [[ -n "${1:-}" && -e "$1" ]]
}

detect_reasons() {
  local id="$1" reasons="" local_app="${LOCALAPPDATA:-}"
  case "$id" in
    cursor)
      have_command cursor && reasons+="command:cursor,"
      path_exists "$local_app/Programs/cursor/Cursor.exe" && reasons+="app,"
      path_exists "$HOME/.cursor" && reasons+="config,"
      ;;
    claude)
      have_command claude && reasons+="command:claude,"
      path_exists "$HOME/.claude" && reasons+="config,"
      ;;
    codex)
      have_command codex && reasons+="command:codex,"
      path_exists "$HOME/.codex" && reasons+="config,"
      ;;
    gemini)
      have_command gemini && reasons+="command:gemini,"
      path_exists "$HOME/.gemini" && reasons+="config,"
      ;;
    antigravity)
      have_command agy && reasons+="command:agy,"
      path_exists "$local_app/Programs/Antigravity/Antigravity.exe" && reasons+="app,"
      if path_exists "$HOME/.gemini/config/plugins" || path_exists "$HOME/.gemini/antigravity-cli"; then
        reasons+="config,"
      fi
      ;;
    windsurf)
      have_command windsurf && reasons+="command:windsurf,"
      path_exists "$local_app/Programs/Windsurf/Windsurf.exe" && reasons+="app,"
      path_exists "$HOME/.codeium/windsurf" && reasons+="config,"
      ;;
    opencode)
      have_command opencode && reasons+="command:opencode,"
      path_exists "$HOME/.config/opencode" && reasons+="config,"
      ;;
    copilot)
      if have_command code && code --list-extensions 2>/dev/null | grep -qi '^github\.copilot$'; then
        reasons+="command:code,extension:github.copilot,"
      fi
      ;;
    copilot-cli)
      have_command copilot && reasons+="command:copilot,"
      path_exists "$HOME/.copilot" && reasons+="config,"
      ;;
    kiro)
      have_command kiro && reasons+="command:kiro,"
      path_exists "$HOME/.kiro" && reasons+="config,"
      ;;
    commandcode)
      have_command commandcode && reasons+="command:commandcode,"
      path_exists "$HOME/.commandcode" && reasons+="config,"
      ;;
  esac
  reasons="${reasons%,}"
  printf '%s' "$reasons"
}

destination_for() {
  local id="$1"
  if [[ "$SCOPE" == "project" ]]; then
    echo "$PROJECT/$(project_skills_for "$id")"
  else
    user_skills_for "$id"
  fi
}

copy_skill_pack() {
  local dest="$1" version="$2" dir name count=0 ref_dest stamp
  mkdir -p "$dest"
  for dir in "$SKILLS_ROOT"/*; do
    [[ -d "$dir" && -f "$dir/SKILL.md" ]] || continue
    name="$(basename "$dir")"
    rm -rf "$dest/$name"
    cp -R "$dir" "$dest/$name"
    count=$((count + 1))
  done
  if [[ -d "$REFERENCES_ROOT" ]]; then
    ref_dest="$(dirname "$dest")/references"
    mkdir -p "$ref_dest"
    cp -R "$REFERENCES_ROOT"/. "$ref_dest"/
  fi
  stamp="$dest/.agent-skills-install.json"
  cat >"$stamp" <<EOF
{
  "version": "$version",
  "installedAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "source": "$REPO_ROOT",
  "skillCount": $count
}
EOF
  echo "$count"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --list) LIST_ONLY=1; shift ;;
    --all) INSTALL_ALL=1; shift ;;
    --only) ONLY_RAW="${2:-}"; shift 2 ;;
    --scope) SCOPE="${2:-}"; shift 2 ;;
    --project) PROJECT="${2:-}"; shift 2 ;;
    --no-aliases) NO_ALIASES=1; shift ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown argument: $1" >&2; usage; exit 1 ;;
  esac
done

if [[ ! -d "$SKILLS_ROOT" ]]; then
  echo "Expected skills at $SKILLS_ROOT" >&2
  exit 1
fi

if [[ -n "$PROJECT" || "$SCOPE" == "project" ]]; then
  SCOPE="project"
  if [[ -z "$PROJECT" ]]; then
    PROJECT="$(pwd)"
  fi
  PROJECT="$(cd "$PROJECT" && pwd)"
fi

interactive=0
if [[ "$LIST_ONLY" -eq 0 && "$INSTALL_ALL" -eq 0 && -z "$ONLY_RAW" ]]; then
  interactive=1
fi

if [[ -z "$SCOPE" && "$interactive" -eq 1 ]]; then
  echo "Scope: [U] user directories for every project, [P] project directory (current folder)"
  read -r -p "Scope: " scope_answer
  scope_answer="$(printf '%s' "$scope_answer" | tr '[:upper:]' '[:lower:]')"
  if [[ "$scope_answer" == "p" || "$scope_answer" == "project" ]]; then
    SCOPE="project"
    PROJECT="$(pwd)"
  else
    SCOPE="user"
  fi
fi
SCOPE="${SCOPE:-user}"

VERSION="$(pack_version)"
SOURCE_COUNT="$(source_skill_count)"

FOUND=()
REASONS=()
STATUS=()
HAVE=()
NEEDS=()
DESTS=()

echo "agent-skills ${VERSION:-unknown}"
echo "Source: $SKILLS_ROOT ($SOURCE_COUNT skills)"
if [[ "$SCOPE" == "project" ]]; then
  echo "Scope:  project -> $PROJECT"
else
  echo "Scope:  user"
fi
echo
printf '%2s  %-14s %-9s %-8s %5s  %s\n' "#" "Id" "Detected" "Status" "Have" "Destination"

for i in "${!IDS[@]}"; do
  id="${IDS[$i]}"
  reasons="$(detect_reasons "$id")"
  dest="$(destination_for "$id")"
  have="$(installed_skill_count "$dest")"
  found=0
  status="absent"
  needs=0
  if [[ -n "$reasons" ]]; then
    found=1
    if marker_installed "$dest"; then
      status="ready"
    else
      status="need"
      needs=1
    fi
  fi
  FOUND[$i]="$found"
  REASONS[$i]="${reasons:-no}"
  STATUS[$i]="$status"
  HAVE[$i]="$have"
  NEEDS[$i]="$needs"
  DESTS[$i]="$dest"
  detected_col="no"
  [[ "$found" -eq 1 ]] && detected_col="yes"
  printf '%2s  %-14s %-9s %-8s %5s  %s\n' "$((i + 1))" "$id" "$detected_col" "$status" "$have" "$dest"
done

echo
echo "Status: need = tool found, pack marker missing; ready = marker present; absent = tool not found."

if [[ "$LIST_ONLY" -eq 1 ]]; then
  exit 0
fi

selected=()
if [[ -n "$ONLY_RAW" ]]; then
  IFS=',' read -r -a selected <<<"$ONLY_RAW"
elif [[ "$INSTALL_ALL" -eq 1 ]]; then
  for i in "${!IDS[@]}"; do
    [[ "${FOUND[$i]}" -eq 1 ]] && selected+=("${IDS[$i]}")
  done
  if [[ ${#selected[@]} -eq 0 ]]; then
    echo "No IDE or CLI detected. Pass --only <id> to install a destination anyway." >&2
    exit 1
  fi
else
  echo "Enter = install every detected target with status need"
  echo "a = every detected target, 1,3 or 1-3 = choose rows, q = quit"
  read -r -p "Install: " answer
  answer="$(printf '%s' "$answer" | tr '[:upper:]' '[:lower:]' | tr -d ' ')"
  if [[ "$answer" == "q" ]]; then
    echo "Cancelled."
    exit 0
  fi
  if [[ -z "$answer" ]]; then
    for i in "${!IDS[@]}"; do
      [[ "${NEEDS[$i]}" -eq 1 ]] && selected+=("${IDS[$i]}")
    done
  elif [[ "$answer" == "a" || "$answer" == "d" ]]; then
    for i in "${!IDS[@]}"; do
      [[ "${FOUND[$i]}" -eq 1 ]] && selected+=("${IDS[$i]}")
    done
  else
    IFS=',' read -r -a tokens <<<"$answer"
    for token in "${tokens[@]}"; do
      if [[ "$token" =~ ^([0-9]+)-([0-9]+)$ ]]; then
        start="${BASH_REMATCH[1]}"
        end="${BASH_REMATCH[2]}"
        if [[ "$start" -gt "$end" ]]; then
          tmp="$start"
          start="$end"
          end="$tmp"
        fi
        for n in $(seq "$start" "$end"); do
          idx=$((n - 1))
          if [[ "$idx" -lt 0 || "$idx" -ge ${#IDS[@]} ]]; then
            echo "Unknown row: $n" >&2
            exit 1
          fi
          selected+=("${IDS[$idx]}")
        done
      elif [[ "$token" =~ ^[0-9]+$ ]]; then
        idx=$((token - 1))
        if [[ "$idx" -lt 0 || "$idx" -ge ${#IDS[@]} ]]; then
          echo "Unknown row: $token" >&2
          exit 1
        fi
        selected+=("${IDS[$idx]}")
      else
        if ! index_of "$token" >/dev/null; then
          echo "Unknown id: $token" >&2
          exit 1
        fi
        selected+=("$token")
      fi
    done
  fi
fi

if [[ ${#selected[@]} -eq 0 ]]; then
  echo "Nothing selected. Detected tools already have the pack marker, or none were detected."
  echo "Choose row numbers, or pass --all to refresh detected targets."
  exit 0
fi

# Unique, preserve order
unique=()
for id in "${selected[@]}"; do
  id="$(printf '%s' "$id" | tr '[:upper:]' '[:lower:]')"
  skip=0
  if [[ ${#unique[@]} -gt 0 ]]; then
    for seen in "${unique[@]}"; do
      [[ "$seen" == "$id" ]] && skip=1
    done
  fi
  [[ "$skip" -eq 1 ]] && continue
  if ! index_of "$id" >/dev/null; then
    echo "Unknown id: $id" >&2
    exit 1
  fi
  unique+=("$id")
done

run_cli() {
  echo "  $*"
  "$@"
}

install_plugin() {
  local id="$1" scope_flag="user"
  [[ "$SCOPE" == "project" ]] && scope_flag="project"
  case "$id" in
    claude)
      if ! have_command claude; then
        echo "  claude is not on PATH. Copying skill folders instead of registering the plugin."
        return 1
      fi
      run_cli claude plugin marketplace add "$REPO_ROOT" --scope "$scope_flag" || return 1
      run_cli claude plugin install agent-skills@addy-agent-skills --scope "$scope_flag" || return 1
      ;;
    codex)
      if ! have_command codex; then
        echo "  codex is not on PATH. Copying skill folders instead of registering the plugin."
        return 1
      fi
      run_cli codex plugin marketplace add "$REPO_ROOT" || return 1
      run_cli codex plugin add agent-skills@agent-skills || return 1
      ;;
    gemini)
      if ! have_command gemini; then
        echo "  gemini is not on PATH. Copying skill folders instead of registering the plugin."
        return 1
      fi
      if [[ "$SCOPE" == "project" ]]; then
        run_cli gemini skills install "$SKILLS_ROOT" --scope workspace || return 1
      else
        run_cli gemini skills install "$SKILLS_ROOT" || return 1
      fi
      ;;
    antigravity)
      if ! have_command agy; then
        echo "  agy is not on PATH. Copying skill folders instead of registering the plugin."
        return 1
      fi
      run_cli agy plugin install "$REPO_ROOT" || return 1
      ;;
    copilot-cli)
      if ! have_command copilot; then
        echo "  copilot is not on PATH. Copying skill folders instead of registering the plugin."
        return 1
      fi
      run_cli copilot plugin marketplace add "$REPO_ROOT" || return 1
      run_cli copilot plugin install agent-skills@addy-agent-skills -y || return 1
      ;;
    *)
      return 1
      ;;
  esac
  return 0
}

failures=0
for id in "${unique[@]}"; do
  idx="$(index_of "$id")"
  echo
  echo "Installing ${LABELS[$idx]}"
  plugin_ok=1
  case "$id" in
    claude|codex|gemini|antigravity|copilot-cli)
      if install_plugin "$id"; then
        plugin_ok=0
        echo "  Registered this clone as a plugin. Open a new session to load it."
        [[ "$id" == "antigravity" ]] && echo "  Antigravity installs that plugin for every project."
      else
        echo "  Copying skill folders instead."
      fi
      ;;
  esac
  if [[ "$plugin_ok" -ne 0 ]]; then
    if copied="$(copy_skill_pack "${DESTS[$idx]}" "${VERSION:-unknown}")"; then
      echo "  Skill folders -> ${DESTS[$idx]}"
      echo "  Copied $copied skills."
      if [[ "${FOUND[$idx]}" -eq 0 ]]; then
        echo "  Tool was not detected. Folders were created for a later install of that IDE/CLI."
      fi
    else
      echo "  Failed: $id" >&2
      failures=$((failures + 1))
      continue
    fi
  fi
  note_for "$id"
done

echo
if [[ "$failures" -gt 0 ]]; then
  echo "Finished with $failures failure(s)."
  exit 1
fi
echo "Installed ${#unique[@]} target(s)."

if [[ "$NO_ALIASES" -eq 0 && -f "$REPO_ROOT/scripts/install-aliases.sh" ]]; then
  alias_args=()
  [[ "$SCOPE" == "project" ]] && alias_args+=(--scope project --project "$PROJECT")
  if [[ ${#unique[@]} -gt 0 ]]; then
    target_list="$(IFS=','; echo "${unique[*]}")"
    alias_args+=(--only "$target_list")
  fi
  echo
  "$REPO_ROOT/scripts/install-aliases.sh" "${alias_args[@]}"
fi
