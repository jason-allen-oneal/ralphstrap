# Ralphstrap

Ralphstrap is a Bash-based bootstrapper for creating **ralph-style agentic projects** using an LLM CLI (Gemini by default). It takes a raw application idea, enforces structure, and materializes a complete project scaffold designed for iterative, agent-driven development.

This is not a demo script. It is a practical tool for rapidly standing up serious agentic codebases with consistency and discipline.

---

## What Ralphstrap Does

Ralphstrap automates the most failure-prone phase of agentic development: turning an idea into an actionable, structured plan.

At a high level, it:

1. Opens your editor and forces you to write a concrete app idea.
2. Wraps that idea in a strict, structured prompt.
3. Sends the prompt to an LLM CLI.
4. Writes the returned files directly into the current working directory.
5. Produces a project layout designed for iterative agent loops.

The output is intentionally opinionated.

---

## Requirements

You must have the following available:

- **Bash**
  - The script explicitly enforces Bash. It will not run under `sh` or `dash`.
- **Gemini CLI** (or compatible LLM CLI)
  - Default binary: `gemini`
  - Override with the `LLM_BIN` environment variable.
- **A terminal editor**
  - Controlled via `$EDITOR`
  - Defaults to `nano` if unset.

If any of these are missing, the script will fail fast.

---

## Quick Start

From the repository root:

~~~bash
bash ralphstrap.sh
~~~

Flow:

1. Your editor opens.
2. You write a clear, concrete application idea.
3. Save and exit the editor.
4. The script validates input and aborts if it is empty.
5. The LLM is invoked with a structured prompt.
6. Generated files are written to disk.

---

## Install for Global Use

You can install Ralphstrap so it is callable from any directory.

### User-local install (recommended)

~~~bash
./install.sh
~~~

Installs to:

~~~text
~/.local/bin/ralphstrap
~~~

Ensure `~/.local/bin` is in your `PATH`.

### System-wide install

~~~bash
TARGET_DIR=/usr/local/bin sudo ./install.sh
~~~

This requires root privileges.

Once installed, you can run:

~~~bash
ralphstrap
~~~

from any project directory.

---

## Generated Project Structure

The LLM output is expected to generate the following files and directories:

~~~text
project_idea.md
AGENTS.md
IMPLEMENTATION_PLAN.md
PROMPT_build.md
PROMPT_plan.md
loop.sh
specs/
src/
~~~

### File Purpose

- **project_idea.md**  
  The raw, user-authored idea captured at bootstrap time.

- **AGENTS.md**  
  Defines agent roles, responsibilities, and boundaries.

- **IMPLEMENTATION_PLAN.md**  
  Step-by-step execution plan for building the project.

- **PROMPT_build.md**  
  Prompt used for code-generation phases.

- **PROMPT_plan.md**  
  Prompt used for planning and refinement phases.

- **loop.sh**  
  The execution loop for ralph-style iterative development.

- **specs/**  
  Reserved for formal specifications.

- **src/**  
  Application source code.

---

## Configuration

Ralphstrap behavior can be adjusted via environment variables:

- **LLM_BIN**  
  Path or name of the LLM CLI binary.  
  Default: `gemini`

- **GEMINI_MODEL**  
  Model passed to the Gemini CLI.  
  Default: `gemini-2.5-flash`

- **EDITOR**  
  Editor used to capture the project idea.  
  Default: `nano`

Example:

~~~bash
export LLM_BIN=gemini
export GEMINI_MODEL=gemini-2.5-pro
export EDITOR=vim
~~~

---

## Design Philosophy

- Force clarity early.
- Fail fast on bad input.
- Prefer structure over flexibility.
- Optimize for iteration, not perfection.
- Treat the LLM as a generator, not a decision-maker.

Ralphstrap exists to remove friction, not judgment.

---

## Notes

- Empty ideas abort execution.
- The script writes files directly to the current directory.
- Review `IMPLEMENTATION_PLAN.md` before executing `loop.sh`.
- This tool assumes you know what you are doing.

---

## License

MIT
