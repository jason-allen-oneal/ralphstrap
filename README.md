# ralphstrap - Ralph-Style Agentic Coding Project Bootstrap

`ralphstrap` is a simple bash script designed to help you quickly bootstrap new software projects following the "ralph-style" agentic coding methodology, as outlined in the [ralph-playbook](https://github.com/ClaytonFarr/ralph-playbook).

## What it Does

This script automates the initial setup phase of a ralph-style project by:

1.  **Collecting Your App Idea:** It prompts you for a detailed description of your application idea.
2.  **Contextualizing for Gemini:** It combines your app idea with a comprehensive summary of the "ralph-style" agentic coding principles (from the ralph-playbook).
3.  **Generating Gemini CLI Prompt:** It constructs a `gemini` command that, when executed, instructs the Gemini CLI to act as an initial agent and generate the core files and directory structure for your new project.

The generated project structure will include:

*   `README.md`: A basic project README.
*   `project_idea.md`: A detailed markdown file of your app idea.
*   `loop.sh`: The main bash script for running the Ralph loop.
*   `PROMPT_build.md`: The prompt file for the 'BUILDING' phase.
*   `PROMPT_plan.md`: The prompt file for the 'PLANNING' phase.
*   `AGENTS.md`: A file for defining sub-agents.
*   `IMPLEMENTATION_PLAN.md`: An initial implementation plan.
*   `specs/` directory: For specifications.
*   `src/` directory: For source code.

## Ralph-Style Agentic Coding

The "ralph-style" methodology emphasizes iterative development, clear goals, self-correction, and heavy reliance on bash scripts for automation. It uses a continuous loop where an AI agent (like Gemini) plans, builds, and refines the project, with `IMPLEMENTATION_PLAN.md` serving as shared state.

## Usage

1.  **Make the script executable:**
    ```bash
    chmod +x ralphstrap.sh
    ```

2.  **Run the script:**
    ```bash
    ./ralphstrap.sh
    ```

3.  **Provide your app idea:**
    The script will prompt you to enter a detailed description of your app idea. Type your idea and press `Ctrl+D` when you are finished.

4.  **Execute the generated Gemini command:**
    The script will output a `gemini` command. Copy this entire command and paste it directly into your Gemini CLI to initiate the project generation.

    ```
    # Example of generated command (actual command will be longer)
    gemini "You are an expert software engineer... [your app idea] ...generate the following files..."
    ```

This will instruct Gemini to generate the initial set of files and directories for your new ralph-style agentic coding project.
