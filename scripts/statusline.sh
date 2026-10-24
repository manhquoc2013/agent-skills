#!/usr/bin/env bash
# scripts/statusline.sh
# Fast statusline indicator for terminal prompt or agent statusbar (<10ms)

mode_flag="${AGENT_SKILLS_MODE_DIR:-$HOME/.config/agent-skills}/mode"
claude_flag="${CLAUDE_CONFIG_DIR:-$HOME/.claude}/.agent-skills-mode"

mode="full"
if [ -f "$mode_flag" ]; then
  mode=$(head -n1 "$mode_flag" | tr -d '[:space:]')
elif [ -f "$claude_flag" ]; then
  mode=$(head -n1 "$claude_flag" | tr -d '[:space:]')
fi

# Detect lifecycle phase from workspace files
phase="READY"
if [ -f "tasks/todo.md" ]; then
  if grep -q '\- \[ \]' "tasks/todo.md" 2>/dev/null; then
    phase="BUILD"
  else
    phase="REVIEW"
  fi
elif [ -f "tasks/plan.md" ]; then
  phase="PLAN"
elif [ -f "SPEC.md" ]; then
  phase="SPEC"
fi

# Color styling
color=75 # Cyan
[ "$mode" = "ultra" ] && color=208 # Orange
[ "$phase" = "BUILD" ] && color=114 # Green
[ "$phase" = "REVIEW" ] && color=141 # Purple

printf '\033[38;5;%sm[%s:%s]\033[0m\n' "$color" "$phase" "$(printf '%s' "$mode" | tr '[:lower:]' '[:upper:]')"
