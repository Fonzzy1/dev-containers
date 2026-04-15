---
name: brainstorm
description: Capture, organize, and connect ideas in a Quarto brainstorm document with auto-classification and synthesis
license: MIT
compatibility: opencode
metadata:
  audience: researchers, writers, explorers
  workflow: idea-capture
---

## What the brainstorm skill does

The brainstorm skill is dispatched by Orchestrator when User provides vague or exploratory input. The skill:

- Creates a new Quarto brainstorm document (`.qmd` file)
- Dispatches to Brainstorm Appender agent to add ideas with auto-classification and tagging
- Dispatches to Brainstorm Synthesizer agent to find connections and generate thesis statements (on request only)
- Manages the brainstorm workflow and shows User the results

## When Orchestrator uses the brainstorm skill

Orchestrator dispatches the brainstorm skill when User provides **vague or exploratory input** — when User is thinking through a topic but hasn't decided on a specific goal yet.

**Examples of input that trigger the brainstorm skill:**

- "I've been thinking about AI ethics and want to explore the topic"
- "Let me brainstorm ideas for a blog post on X"
- "I want to capture some thoughts on Y and see what connections emerge"
- "Help me organize my ideas about Z"

**When Orchestrator does NOT use the brainstorm skill:**

- User has a specific, defined goal (Orchestrator dispatches to Engineer, Writer, or Researcher instead)
- User wants to write a finished document (Orchestrator dispatches to Writer agent)
- User wants to research a topic (Orchestrator dispatches to Researcher agent)
- User wants to execute code or build something (Orchestrator dispatches to Engineer agent)

## Workflow: Orchestrator dispatches the brainstorm skill

### Orchestrator initiates the brainstorm

Orchestrator recognizes vague/exploratory input from User and dispatches the brainstorm skill:

```
Orchestrator: "Orchestrator recommends the brainstorm skill to explore this topic and clarify a goal."
```

Either the user will have already made a file, or the orchestrator should delegate to an admin bot to get the first idea.

Initial file should just have the tile and the date

### User adds ideas (via the brainstorm skill)

User sends ideas, thoughts, questions, or observations:

```
Models should disclose what data they were trained on
```

The brainstorm skill dispatches to Brainstorm Appender agent, which classifies, tags, and annotates the idea. The skill shows User the result.

### User requests synthesis (via the brainstorm skill)

User sends:

```
synthesize
```

The brainstorm skill dispatches to Brainstorm Synthesizer agent, which finds connections and generates thesis statements. The skill shows User the results.

### User transitions to a defined task

Once User has a solid brainstorm, User can ask Orchestrator to use the brainstorm as input for a defined task:

```
User: "Write a blog post based on this brainstorm"
Orchestrator: [dispatches to Writer agent with the brainstorm file as context]
```

## How the brainstorm skill orchestrates the workflow

The brainstorm skill dispatches to two specialist agents:

- **Brainstorm Appender agent** — classifies ideas, generates tags, and writes annotations
- **Brainstorm Synthesizer agent** — finds connections and generates thesis statements (only when User explicitly requests synthesis)

The skill manages the workflow, dispatches to agents, and shows User results via the `open_open` tool.

See the agent configs for details on how ideas are classified, tagged, and synthesized.

## Key behaviors

- **Synthesis on request only** — Brainstorm Synthesizer only acts when User explicitly asks
- **Grounded synthesis** — thesis statements are always based on existing ideas
- **Append-only** — ideas are never deleted or reordered
- **Tag reuse** — existing tags are prioritized for consistency

## Tips for User

- **Add freely** — User can capture all ideas, even half-formed ones
- **Synthesize iteratively** — User can add more ideas, then ask for synthesis again to find new connections
- **Transition to defined tasks** — once User has a solid brainstorm, User can ask Orchestrator to use it as input for a defined task (e.g., "Write a blog post based on this brainstorm")

## Limitations

- **Not for defined tasks** — if User has a specific goal (write a blog post, build a feature), Orchestrator dispatches to Engineer, Writer, or Researcher instead
- **Not for research** — if User needs to gather sources, Orchestrator dispatches to Researcher agent
- **Not for execution** — if User needs to run code or build something, Orchestrator dispatches to Engineer agent
- **Synthesis is grounded** — thesis statements only connect existing ideas; the skill won't create new claims

## What happens after the brainstorm

Once User has a solid brainstorm:

1. **User transitions to a defined task** — User asks Orchestrator to use the brainstorm as input (e.g., "Write a blog post based on this brainstorm"), and Orchestrator dispatches to the appropriate agent
2. **User exports to PDF** — User can share the brainstorm with their team or include in documentation
3. **User continues exploring** — User can add more ideas and ask for synthesis again
4. **User archives it** — User can save the brainstorm for future reference
