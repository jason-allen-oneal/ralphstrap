#!/usr/bin/env bash
set -uo pipefail

# Enforce bash
if [[ -z "${BASH_VERSION:-}" ]]; then
  echo "ERROR: This script must be run with bash." >&2
  exit 1
fi

# ---------------- CONFIG ----------------
RALPH_PLAYBOOK_URL="https://github.com/ClaytonFarr/ralph-playbook"
LLM_BIN="${LLM_BIN:-gemini}"
GEMINI_MODEL="gemini-2.5-flash"
EDITOR_BIN="${EDITOR:-nano}"
# ----------------------------------------

echo "Ralphstrap: bootstrapping agentic project"
echo "----------------------------------------"
echo "An editor will open for your app idea."
echo "Write freely, save, and close the editor."
echo "----------------------------------------"

# ----------- INPUT VIA EDITOR -----------
TMP_IDEA_FILE="$(mktemp /tmp/ralphstrap_idea.XXXXXX.md)"

cat >"$TMP_IDEA_FILE" <<'EOF'
# Write your app idea below.
# Markdown, JSON, and blank lines are allowed.

EOF

"$EDITOR_BIN" "$TMP_IDEA_FILE"

if [[ ! -s "$TMP_IDEA_FILE" ]]; then
  echo "ERROR: App idea file is empty." >&2
  rm -f "$TMP_IDEA_FILE"
  exit 1
fi

APP_IDEA="$(cat "$TMP_IDEA_FILE")"
rm -f "$TMP_IDEA_FILE"

# Trim leading/trailing empty lines only
APP_IDEA="$(printf "%s" "$APP_IDEA" \
  | sed -e '1{/^[[:space:]]*$/d;}' -e '${/^[[:space:]]*$/d;}')"

if [[ -z "$APP_IDEA" ]]; then
  echo "ERROR: App idea cannot be empty." >&2
  exit 1
fi
# ----------------------------------------

read -r -d '' RALPH_STYLE_SUMMARY <<EOF
The 'ralph-style' of agentic coding, as described in the ralph-playbook ($RALPH_PLAYBOOK_URL), emphasizes:

- Iterative planning and building loops
- Disk-persisted plans (IMPLEMENTATION_PLAN.md)
- Markdown-first coordination
- Deterministic backpressure via plans, tests, and structure
- Bash-driven outer loop with LLM inner loop
EOF

read -r -d '' GEMINI_PROMPT <<EOF
You are an expert software engineer following ralph-style agentic coding.

APP IDEA:
$APP_IDEA

RALPH PRINCIPLES:
$RALPH_STYLE_SUMMARY

OUTPUT REQUIREMENTS (STRICT):
- Emit ONLY file blocks
- Use this exact format:

=== FILE: relative/path ===
<file content>
=== END FILE ===

FILES TO GENERATE:
- project_idea.md
- loop.sh
- PROMPT_build.md
- PROMPT_plan.md
- AGENTS.md
- IMPLEMENTATION_PLAN.md
- Create empty dirs: specs/, src/

Do not explain anything. Only emit file blocks.
EOF

echo "Invoking Gemini with model: $GEMINI_MODEL"

if ! command -v "$LLM_BIN" >/dev/null 2>&1; then
  echo "ERROR: gemini CLI not found in PATH." >&2
  exit 1
fi

tmp_out="$(mktemp)"
tmp_err="$(mktemp)"

"$LLM_BIN" \
  "$GEMINI_PROMPT" \
  -m "$GEMINI_MODEL" \
  >"$tmp_out" 2>"$tmp_err"

rc=$?

LLM_OUTPUT="$(cat "$tmp_out")"
LLM_ERR="$(cat "$tmp_err")"
rm -f "$tmp_out" "$tmp_err"

if [[ $rc -ne 0 ]]; then
  echo "ERROR: Gemini failed (exit code $rc)" >&2
  if [[ -n "$LLM_ERR" ]]; then
    echo "----- Gemini stderr -----" >&2
    printf "%s\n" "$LLM_ERR" >&2
  fi
  exit 1
fi

if [[ -z "$LLM_OUTPUT" ]]; then
  echo "ERROR: Gemini returned no output." >&2
  exit 1
fi

echo "Materializing files..."
echo "----------------------------------------"

current_file=""
buffer=""

while IFS= read -r line; do
  if [[ "$line" =~ ^===\ FILE:\ (.+)\ ===$ ]]; then
    current_file="${BASH_REMATCH[1]}"
    buffer=""
    continue
  fi

  if [[ "$line" == "=== END FILE ===" ]]; then
    mkdir -p "$(dirname "$current_file")"
    printf "%s" "$buffer" >"$current_file"
    echo "Wrote: $current_file"
    current_file=""
    buffer=""
    continue
  fi

  [[ -n "$current_file" ]] && buffer+="${line}"$'\n'
done <<< "$LLM_OUTPUT"

mkdir -p specs src

echo "----------------------------------------"
echo "Bootstrap complete."
echo "Next step: review IMPLEMENTATION_PLAN.md and run loop.sh"
