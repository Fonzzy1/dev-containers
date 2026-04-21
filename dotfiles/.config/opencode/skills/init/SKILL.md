---
name: init
description: Discover a repository, ask clarifying questions, and produce or improve a README.md for that repo
license: MIT
compatibility: opencode
metadata:
  audience: developers, documentation writers
  workflow: documentation-creation
---

## What the init skill does

The init skill is dispatched when User wants to create or improve a README.md for a repository. The skill:

- Dispatches to Researcher agent to perform deep discovery on the repository files
- Asks clarifying questions to understand the repo's purpose, structure, and audience
- Uses the gathered information to draft or improve README.md with clear explanations of setup, usage, and key features
- Places the final README.md in the appropriate location within the repository (not /tmp)

## When Orchestrator uses the init skill

Orchestrator dispatches the init skill when User provides input indicating they want documentation for a repository.

**Examples of input that trigger the init skill:**

- "Make a README for this repo"
- "The repo has no documentation, can you add a README.md?"
- "Help me understand what this project does by creating a README"
- "I need to document this repository"

**When Orchestrator does NOT use the init skill:**

- User has a specific, well-defined goal (Orchestrator dispatches to Engineer, Writer, or Researcher instead)
- User wants to write a finished document (Orchestrator dispatches to Writer agent)
- User wants to research a topic (Orchestrator dispatches to Researcher agent)
- User wants to execute code or build something (Orchestrator dispatches to Engineer agent)

## Workflow: Repository discovery via the Researcher

### First step: Dispatch to Researcher for deep discovery

Orchestrator recognizes that User wants documentation for a repository. The init skill immediately dispatches to Researcher agent to perform deep discovery on the repository files.

**Key discovery areas:**

- Main entry points and core functionality
- Directory structure and organization
- Dependencies and configuration files
- Testing setup and commands
- Build scripts and automation
- License and contribution guidelines

The Researcher performs thorough exploration of the codebase to gather complete context before any documentation work begins.

### Second step: Ask clarifying questions

After the initial discovery, the init skill asks clarifying questions to understand the repository from the user's perspective. **The skill asks questions until it has enough context to draft a README.** Do not skip this step — insufficient context leads to poor documentation.

**Essential questions to answer:**

- What is the primary purpose of this repository? What problem does it solve?
- Who is the intended audience? (developers, researchers, end users, etc.)
- What are the key features or capabilities?
- What is the expected workflow for someone using this repo?
- Are there any specific conventions or patterns to highlight?
- What installation or setup steps are required?
- Are there any known limitations or gotchas?

**How many questions to ask:** Ask a heap of questions. Keep asking until the skill has a clear picture. If anything is unclear, ask. It is better to over-ask than to draft based on assumptions.

### Third step: Draft README.md

Once enough information is gathered, the init skill drafts or improves README.md with clear sections:

- Project title and one-line description
- High-level overview of what the repo does
- Installation and setup instructions
- Usage examples and commands
- Key features and capabilities
- Configuration and environment variables
- Testing and development commands
- License and contribution information

**Where to place the output:** Write the README.md to the repository root (or appropriate location specified by the user). This is the final artifact, not a draft in /tmp. The README belongs in the repo.

**Guardrails: When to ask more questions vs. when to draft**

- If essential sections (purpose, audience, usage) are unclear: **ask more questions first**
- If the skill has enough information to answer the core questions: **proceed to draft**
- If the user provides unclear or incomplete context: **ask more questions before starting**
- If the user explicitly provides all needed context: **draft directly**

## Key behaviors

- **Thorough discovery first** — Researcher agent explores the repository structure before any documentation work
- **Iterative questioning** — skill asks clarifying questions until it has enough context to draft a quality README
- **No assumptions** — do not guess at unclear aspects; ask instead
- **Final artifact placement** — README.md goes in the repository root, not /tmp
- **Clear sections** — README includes installation, usage, configuration, and contribution details

## Limitations

- **Not for vague input** — if User provides unclear or incomplete context, the skill asks more questions before proceeding
- **Not for other documentation** — the init skill focuses specifically on README.md, not general documentation or wikis
- **Not for code execution** — the skill documents what exists, it doesn't modify the codebase itself
- **Not for research-only tasks** — if User only wants exploration without documentation, dispatch to Researcher instead
