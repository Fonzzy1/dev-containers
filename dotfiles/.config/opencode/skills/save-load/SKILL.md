---
name: save-load
description: Save and load Orchestrator task state for resuming interrupted workflows
license: MIT
compatibility: opencode
metadata:
  audience: orchestrators, task managers
  workflow: task-persistence
---

## What the save-load skill does

The save-load skill allows Orchestrator to persist task state to a `.opencode_save` file and resume from that state later. This is useful for:

- Long-running tasks that span multiple sessions
- Preserving context when switching between projects
- Recovering from interruptions without losing progress
- Maintaining a clear audit trail of what was done

The skill captures:
- Current todo list (task names, status, priority)
- Commit messages written so far
- Specialist dispatch history (who did what, when)
- User feedback and decisions made
- File changes and git status
- Timestamps for each action

## When Orchestrator uses the save-load skill

Orchestrator uses the save-load skill in two scenarios:

### 1. Saving task state (mid-task)

When a task is long-running or complex, Orchestrator can save the current state:

```
Orchestrator: "Saving task state to .opencode_save for later resumption."
```

This captures everything needed to resume exactly where work left off.

### 2. Loading task state (resuming)

When returning to a saved task, Orchestrator loads the state:

```
Orchestrator: "Loading task state from .opencode_save..."
```

Orchestrator then:
- Restores the todo list with current status
- Reads git changes since last save
- Identifies what work remains
- Continues from the next pending task

## Workflow: Save and Load

### Saving Task State

Orchestrator saves state by calling the skill with the `save` action:

```
User: "Save the current task state"
Orchestrator: [dispatches to save-load skill with save action]
```

The skill:
1. Reads the current todo list (from todowrite context)
2. Reads pending commit message (from `.git/LAZYGIT_PENDING_COMMIT`)
3. Reads git status and recent commits
4. Captures all task metadata
5. Writes everything to `.opencode_save` as JSON
6. Shows User the saved state

### Loading Task State

Orchestrator loads state by calling the skill with the `load` action:

```
User: "Resume the saved task"
Orchestrator: [dispatches to save-load skill with load action]
```

The skill:
1. Reads `.opencode_save` file
2. Extracts todo list, commit messages, dispatch history
3. Checks git status for changes since save
4. Identifies completed work vs. remaining work
5. Restores Orchestrator context with full history
6. Clears `.opencode_save` file (optional, can keep for audit trail)
7. Shows User the restored state and next steps

## Save File Format

The `.opencode_save` file is a JSON file with this structure:

```json
{
  "version": "1.0",
  "timestamp": "2026-04-15T12:34:56Z",
  "task_description": "Description of the overall task",
  "todos": [
    {
      "content": "Task name",
      "status": "pending|in_progress|completed|cancelled",
      "priority": "high|medium|low"
    }
  ],
  "commit_messages": [
    {
      "step": 1,
      "message": "Commit message text",
      "status": "written|committed",
      "timestamp": "2026-04-15T12:00:00Z"
    }
  ],
  "dispatch_history": [
    {
      "step": 1,
      "agent": "engineer|writer|researcher|admin|summariser|supervisor",
      "task": "Brief description of work",
      "status": "dispatched|completed|failed",
      "timestamp": "2026-04-15T12:05:00Z",
      "result_summary": "What was accomplished"
    }
  ],
  "user_decisions": [
    {
      "step": 1,
      "decision": "Description of user choice or feedback",
      "timestamp": "2026-04-15T12:10:00Z"
    }
  ],
  "git_state": {
    "branch": "main",
    "last_commit": "abc123def456...",
    "staged_files": ["file1.md", "file2.ts"],
    "modified_files": ["file3.py"],
    "untracked_files": []
  },
  "notes": "Any additional context or notes"
}
```

## Key behaviors

- **Comprehensive capture** — saves all important state, not just todos
- **Git-aware** — tracks file changes and commit status
- **Timestamp tracking** — records when each action occurred
- **Audit trail** — preserves full history of decisions and work
- **Resumable** — contains everything needed to pick up exactly where work left off
- **Optional cleanup** — `.opencode_save` can be kept for audit or deleted after loading

## Tips for Orchestrator

- **Save at natural breakpoints** — save after completing a major step or before a long dispatch
- **Save before context switches** — if switching projects, save the current task state
- **Load with context** — when loading, review the history to understand what was done
- **Check git status** — after loading, verify that git status matches expectations
- **Clear when done** — optionally delete `.opencode_save` after task completion for cleanliness

## Integration with Orchestrator Workflow

The save-load skill integrates seamlessly with Orchestrator's core workflow:

1. **After Step 3 (Dispatch)** — Orchestrator can save state before a long specialist dispatch
2. **Between Steps** — Orchestrator can save state between multi-step tasks
3. **On Resumption** — Orchestrator loads state and continues from the next pending task
4. **At Completion** — Orchestrator optionally clears the save file

The skill does not interrupt the normal workflow — it's an optional enhancement for long-running or complex tasks.
