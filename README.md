# Ralphstrap

Bootstrap a ralph-style agentic project by feeding an app idea to the Gemini CLI. The script opens an editor for your idea, sends a structured prompt to Gemini, and materializes the generated files into the current directory.

## Requirements
- bash (the script enforces running under bash)
- Gemini CLI available as `gemini` or another binary set via `LLM_BIN`
- An editor in `$EDITOR` (defaults to `nano`)

## Quickstart
1. Make sure the Gemini CLI is installed and logged in.
2. (Optional) Export `LLM_BIN` to point at your Gemini binary and `EDITOR` to your preferred editor.
3. Run the script from the repo root:
   ```bash
   bash ralphstrap.sh
   ```
4. Describe your app idea in the editor that opens, save, and close it.
5. The script calls Gemini with the prompt and writes the returned files into the repo.

## Install for Anywhere Use
Install the script onto your PATH so you can run `ralphstrap` from any directory:
- Default (no sudo): `./install.sh` installs to `~/.local/bin/ralphstrap`.
- Alternate target: `TARGET_DIR=/usr/local/bin sudo ./install.sh` installs system-wide.
- Ensure the chosen target directory is on your `PATH`, then run `ralphstrap` from any directory.

## What Gets Generated
The model output is expected to create these files/directories:
- `project_idea.md`
- `loop.sh`
- `PROMPT_build.md`
- `PROMPT_plan.md`
- `AGENTS.md`
- `IMPLEMENTATION_PLAN.md`
- Empty directories: `specs/`, `src/`

## Configuration
- `LLM_BIN`: Gemini CLI executable (default: `gemini`).
- `GEMINI_MODEL`: Model passed to the CLI (default: `gemini-2.5-flash`).
- `EDITOR`: Editor used to capture the app idea (default: `nano`).
- `RALPH_PLAYBOOK_URL`: Reference to the ralph-style playbook used in the prompt.

## Tips
- The script enforces non-empty input; blank ideas abort the run.
- Review `IMPLEMENTATION_PLAN.md` after generation, then follow the loop in `loop.sh` per the ralph-style flow.
