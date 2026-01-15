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

mkdir -p specs src
touch src/README.md IMPLEMENTATION_PLAN.md gate.sh

cat >"PROMPT_build.md" <<'EOF'
0a. Study `specs/*` with up to 10 parallel gemini-2.5-flash subagents to learn the application specifications.
0b. Study @IMPLEMENTATION_PLAN.md.
0c. For reference, the application source code is in `src/*`.

1A. Your task is to implement functionality per the specifications using parallel subagents. Follow @IMPLEMENTATION_PLAN.md and choose the most important item to address. Create unit tests that test for the end result of your task from @IMPLEMENTATION_PLAN.md. Hook those tests into gate.sh to be run from loop.sh.
1B. Before making changes, search the codebase (don't assume not implemented) using gemini-2.5-flash subagents. You may use up to 10 parallel gemini-2.5-flash subagents for searches/reads and only 1 gemini-2.5-flash subagent for build/tests. Use gemini-3-flash subagents when complex reasoning is needed (debugging, architectural decisions).
2. After implementing functionality or resolving problems, run the tests for that unit of code that was improved. If functionality is missing then it's your job to add it as per the application specifications. Use Reasoning.
3. When you discover issues, immediately update @IMPLEMENTATION_PLAN.md with your findings using a subagent. When resolved, update and remove the item.
4. When the tests pass, update @IMPLEMENTATION_PLAN.md, then `git add -A` then `git commit` with a message describing the changes. After the commit, `git push`.

99999. Important: When authoring documentation, capture the why — tests and implementation importance.
999999. Important: Single sources of truth, no migrations/adapters. If tests unrelated to your work fail, resolve them as part of the increment.
9999999. As soon as there are no build or test errors create a git tag. If there are no git tags start at 0.0.0 and increment patch by 1 for example 0.0.1  if 0.0.0 does not exist.
99999999. You may add extra logging if required to debug issues.
999999999. Keep @IMPLEMENTATION_PLAN.md current with learnings using a subagent — future work depends on this to avoid duplicating efforts. Update especially after finishing your turn.
9999999999. When you learn something new about how to run the application, update @AGENTS.md using a subagent but keep it brief. For example if you run commands multiple times before learning the correct command then that file should be updated.
99999999999. For any bugs you notice, resolve them or document them in @IMPLEMENTATION_PLAN.md using a subagent even if it is unrelated to the current piece of work.
999999999999. Implement functionality completely. Placeholders and stubs waste efforts and time redoing the same work.
9999999999999. When @IMPLEMENTATION_PLAN.md becomes large periodically clean out the items that are completed from the file using a subagent.
99999999999999. If you find inconsistencies in the specs/* then use an gemini-3-pro subagent with 'ultrathink' requested to update the specs.
999999999999999. IMPORTANT: Keep @AGENTS.md operational only — status updates and progress notes belong in `IMPLEMENTATION_PLAN.md`. A bloated AGENTS.md pollutes every future loop's context.
EOF

cat >"PROMPT_plan.md" <<'EOF'
0a. Study `specs/*` with up to 5 parallel gemini-2.5-flash subagents to learn the application specifications.
0b. Study @IMPLEMENTATION_PLAN.md (if present) to understand the plan so far.
0c. Study `src/lib/*` with up to 5 parallel gemini-2.5-flash subagents to understand shared utilities & components.
0d. For reference, the application source code is in `src/*`.

1. Study @IMPLEMENTATION_PLAN.md (if present; it may be incorrect) and use up to 10 gemini-2.5-flash subagents to study existing source code in `src/*` and compare it against `specs/*`. Use an gemini-3-flash subagent to analyze findings, prioritize tasks, and create/update @IMPLEMENTATION_PLAN.md as a bullet point list sorted in priority of items yet to be implemented. Use reasoning. Consider searching for TODO, minimal implementations, placeholders, skipped/flaky tests, and inconsistent patterns. Study @IMPLEMENTATION_PLAN.md to determine starting point for research and keep it up to date with items considered complete/incomplete using subagents.

IMPORTANT: Plan only. Do NOT implement anything. Do NOT assume functionality is missing; confirm with code search first. Treat `src/lib` as the project's standard library for shared utilities and components. Prefer consolidated, idiomatic implementations there over ad-hoc copies.

ULTIMATE GOAL: We want to achieve [project-specific goal]. Consider missing elements and plan accordingly. If an element is missing, search first to confirm it doesn't exist, then if needed author the specification at specs/FILENAME.md. If you create a new element then document the plan to implement it in @IMPLEMENTATION_PLAN.md using a subagent.
EOF

cat >"loop.sh" <<'EOF'
#!/bin/bash
# Usage: ./loop.sh [plan] [max_iterations]
# Examples:
#   ./loop.sh              # Build mode, unlimited iterations
#   ./loop.sh 20           # Build mode, max 20 iterations
#   ./loop.sh plan         # Plan mode, unlimited iterations
#   ./loop.sh plan 5       # Plan mode, max 5 iterations

# Parse arguments
if [ "$1" = "plan" ]; then
    # Plan mode
    MODE="plan"
    PROMPT_FILE="PROMPT_plan.md"
    MAX_ITERATIONS=${2:-0}
elif [[ "$1" =~ ^[0-9]+$ ]]; then
    # Build mode with max iterations
    MODE="build"
    PROMPT_FILE="PROMPT_build.md"
    MAX_ITERATIONS=$1
else
    # Build mode, unlimited (no arguments or invalid input)
    MODE="build"
    PROMPT_FILE="PROMPT_build.md"
    MAX_ITERATIONS=0
fi

ITERATION=0
CURRENT_BRANCH=$(git branch --show-current)

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Mode:   $MODE"
echo "Prompt: $PROMPT_FILE"
echo "Branch: $CURRENT_BRANCH"
[ $MAX_ITERATIONS -gt 0 ] && echo "Max:    $MAX_ITERATIONS iterations"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Verify prompt file exists
if [ ! -f "$PROMPT_FILE" ]; then
    echo "Error: $PROMPT_FILE not found"
    exit 1
fi

while true; do
    if [ $MAX_ITERATIONS -gt 0 ] && [ $ITERATION -ge $MAX_ITERATIONS ]; then
        echo "Reached max iterations: $MAX_ITERATIONS"
        break
    fi

    gemini "$PROMPT_FILE" -y -m gemini-3-flash -o json

    # Push changes after each iteration
    git push origin "$CURRENT_BRANCH" || {
        echo "Failed to push. Creating remote branch..."
        git push -u origin "$CURRENT_BRANCH"
    }

    ITERATION=$((ITERATION + 1))
    echo -e "\n\n======================== LOOP $ITERATION ========================\n"
done
EOF

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
- AGENTS.md (explaining how to run the app, install dependencies, run tests, etc. Per the ralph-playbook.)
- gate.sh (will contain tests to be run from loop.sh. update the existing loop.sh to be able to run tests systematically.)

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

echo "----------------------------------------"
echo "Bootstrap complete."
echo "Next step: review IMPLEMENTATION_PLAN.md and run loop.sh"
