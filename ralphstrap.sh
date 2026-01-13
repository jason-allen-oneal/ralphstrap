#!/bin/bash

# ralphstrap.sh - A bootstrap script for ralph-style agentic coding projects.
# This script takes an app idea from the user and generates an initial project
# structure and prompts for the Gemini CLI, following the ralph-playbook principles.

RALPH_PLAYBOOK_URL="https://github.com/ClaytonFarr/ralph-playbook"

echo "Welcome to Ralphstrap! Let's bootstrap your new agentic coding project."
echo "--------------------------------------------------------------------"

# Prompt for the app idea
echo "Please provide a detailed description of your app idea. Be as specific as possible:"
echo "(Press Ctrl+D when you are finished typing)"
APP_IDEA=$(cat)

if [ -z "$APP_IDEA" ]; then
    echo "Error: App idea cannot be empty. Please try again."
    exit 1
fi

# Summarized ralph-style principles for context
RALPH_STYLE_SUMMARY="
The 'ralph-style' of agentic coding, as described in the ralph-playbook ($RALPH_PLAYBOOK_URL), emphasizes:

**Workflow Phases:**
1.  **Define Requirements (LLM conversation):** Discuss project ideas, identify Jobs to Be Done (JTBD), break into topics, use subagents to load context, and write specifications.
2.  **Run Ralph Loop (two modes):**
    *   **PLANNING mode:** Generates or updates \`IMPLEMENTATION_PLAN.md\`.
    *   **BUILDING mode:** Implements from the plan, commits changes, and updates the plan.

**Key Principles of Ralph:**
*   **Context Is Everything:** Efficient use of context windows, main agent as scheduler, subagents as memory extensions, simplicity, brevity, Markdown over JSON.
*   **Steering Ralph: Patterns + Backpressure:** Use signals and gates (deterministic setup, existing code patterns, tests, typechecks, linters) to steer output.
*   **Let Ralph Ralph:** Trust self-identification, self-correction, and self-improvement through iteration. Run in isolated environments.
*   **Move Outside the Loop:** User engineers the setup and environment, observes, and course-corrects.

**Loop Mechanics:**
*   Outer loop: Controlled by a simple bash script (e.g., \`loop.sh\`) continuously feeding a prompt file to an LLM.
*   Shared state: \`IMPLEMENTATION_PLAN.md\` persists on disk.
*   Inner loop: Task execution controlled by scope discipline, backpressure, and natural completion.

**Core Files/Directories:**
\`loop.sh\`, \`PROMPT_build.md\`, \`PROMPT_plan.md\`, \`AGENTS.md\`, \`IMPLEMENTATION_PLAN.md\`, \`specs/\`, \`src/\`.
"

# Construct the prompt for Gemini CLI
GEMINI_PROMPT="
You are an expert software engineer specializing in agentic coding following the 'ralph-style' principles.
The user wants to create a new application with the following idea:

--- APP IDEA ---
$APP_IDEA
--- END APP IDEA ---

Here is a summary of the 'ralph-style' agentic coding principles from the ralph-playbook ($RALPH_PLAYBOOK_URL):

--- RALPH STYLE SUMMARY ---
$RALPH_STYLE_SUMMARY
--- END RALPH STYLE SUMMARY ---

Your task is to act as the initial agent for this project. Based on the app idea and the 'ralph-style' principles, generate the following:

1.  **A high-level development plan:** Outline the major steps to build this application, broken down into ralph-style iterative tasks. This plan should be suitable for inclusion in an \`IMPLEMENTATION_PLAN.md\` file, starting with the "Define Requirements" phase.
2.  **Initial project files and directories:**
    *   \`README.md\`: A basic README for the new project, explaining its purpose and how to get started with the Ralph loop.
    *   \`project_idea.md\`: A detailed markdown file containing the user's app idea.
    *   \`loop.sh\`: A bash script to run the Ralph loop. It should be a basic loop that continuously feeds a prompt file to an LLM (e.g., \`gemini\`) and updates \`IMPLEMENTATION_PLAN.md\`. Include placeholders for LLM interaction.
    *   \`PROMPT_build.md\`: A markdown file containing the prompt for the 'BUILDING' mode of the Ralph loop.
    *   \`PROMPT_plan.md\`: A markdown file containing the prompt for the 'PLANNING' mode of the Ralph loop.
    *   \`AGENTS.md\`: A markdown file describing any sub-agents or their roles, if applicable to the initial setup.
    *   \`IMPLEMENTATION_PLAN.md\`: An initial implementation plan based on the high-level development plan you generated.
    *   Create the following empty directories: \`specs/\` and \`src/\`.

For the bash scripts, ensure they are executable (\`chmod +x\`) and include comments explaining their purpose.
Present the output as a series of file blocks, clearly indicating the filename and content.
"

echo "--------------------------------------------------------------------"
echo "Generated Gemini CLI Command (copy and paste this into your Gemini CLI):"
echo "--------------------------------------------------------------------"
echo "gemini \"$GEMINI_PROMPT\""
echo "--------------------------------------------------------------------"
echo "Please execute the command above in your Gemini CLI to generate the initial project files."
