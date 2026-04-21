# dev-containers

Personal dev container setup with Neovim + OpenCode preconfigured. Builds the `fonzzy1/vim` Docker image and provides `setup` + `runit` scripts to bootstrap the local environment and open development containers.

---

## Overview

This repository is infrastructure-as-code for a personalized development workflow. It bundles a complete development environment — R, Python, Node, Rust, Quarto, OpenCode, Neovim, and all tooling — inside a Docker container, keeping the host machine clean while providing a reproducible, portable environment.

**Core value**: Your development environment travels with you inside containers. Clone any repo, mount it, and get immediately productive with your configured editor, dotfiles, and helper scripts.

---

## Repo Layout

| File/Directory                            | Purpose                                                                                               |
| ----------------------------------------- | ----------------------------------------------------------------------------------------------------- |
| `Dockerfile`                              | Defines `fonzzy1/vim:latest` — installs all tooling (R, Python, Node, Rust, Quarto, OpenCode, Neovim) |
| `build`                                   | Shell wrapper around `docker build`; skips rebuild if source files unchanged                          |
| `runit`                                   | Python entrypoint for running containers with host directories mounted                                |
| `setup`                                   | Host bootstrap script; installs GNOME, Kitty, Docker on a fresh machine (**run once only**)           |
| `dotfiles/`                               | User environment config copied into the image (bash, OpenCode, feeds, lazygit, marksman)              |
| `dotfiles/.config/opencode/opencode.json` | OpenCode permissions and config for the container                                                     |
| `dotfiles/.config/opencode/agents/`       | Custom agent configs wired into the container                                                         |
| `dotfiles/.config/opencode/tools/`        | Custom tools: PDF extraction, RSS reader, and URL/opener                                              |
| `dotfiles/feeds/*.opml`                   | OPML feed collections (news, academic, arxiv, pods)                                                   |
| `vim/`                                    | Neovim configuration — plugins, lua configs, and toggletasks                                          |
| `run_scripts/`                            | Helper scripts copied to `/scripts` inside the image                                                  |
| `test/test.qmd`                           | Quarto test document wired to callouts.lua                                                            |

---

## Building the Image

```bash
sh ./build
```

The `build` script is preferred over raw `docker build` because it:

- Skips the rebuild if no changes detected in `Dockerfile`, `dotfiles/`, `vim/`, or `run_scripts/`
- Optionally logs into DockerHub if `$DOKER_USER` and `$DOCKER_TOKEN` are set
- Always tags the image as `fonzzy1/vim:latest`

After building, run containers using `runit` (see below).

---

## Running Containers

All commands run **on the host**:

| Command                                  | Description                                                          |
| ---------------------------------------- | -------------------------------------------------------------------- |
| `python3 runit` or `python3 runit local` | Mount current directory into container, open Neovim                  |
| `python3 runit --kitty`                  | Open separate Kitty window running OpenCode on port 3000             |
| `python3 runit gh owner/repo`            | Clone GitHub repo into `~/Documents/owner-repo`, open in container   |
| `python3 runit config`                   | Edit this repo (`/dev-containers`) inside its own container          |
| `python3 runit audio`                    | Run podcast workflow with extra host mounts                          |
| `python3 runit setup --init`             | **Full host bootstrap** — install GNOME/Kitty/Docker (run once only) |

> **Note**: The `--kitty` flag opens a separate Kitty window that runs OpenCode inside the container, giving you a graphical IDE experience alongside Neovim.

---

## Host Bootstrap Warning

`python3 runit setup --init` installs system packages, a desktop environment (GNOME), terminal emulator (Kitty), and Docker on the host machine. This is a one-time bootstrap step — **do not run casually**.

- Agents should **never** invoke `setup` unless explicitly asked by the user to set up a new machine.
- This is host-level infrastructure, not a development script.
- Treat `setup` as user-only bootstrapping, not something agents use in normal workflow.

---

## OpenCode & Neovim Workflow

Inside the container:

- **Neovim** is the primary editor, preconfigured with custom plugins and the `:Summarise` command for extracting claims from PDFs via `pdftotext` + OpenCode.
- **OpenCode** is configured with custom agents and tools

---

## Notes & Gotchas

- **Not a conventional app repo**: No `package.json`, `pyproject.toml`, or test runner. Focus is on Dockerfile, dotfiles, Neovim config, and helper scripts.
- **Source directories are copied into the image**: Changes to `dotfiles/`, `vim/`, or `run_scripts/` are baked in at build time. Validate that paths and context make sense inside the container.
- **OpenCode permissions restrict file operations**: Operations outside `/tmp` require explicit permission in the container config.
- **Quarto testing**: There's a test document at `test/test.qmd` wired to `/scripts/callouts.lua` — useful for validating Quarto workflows.

---

## Intended Audience

This repository is personal infrastructure — tailored for a single-user workflow and their agents. It can serve as a reference for similar setups, but the configuration is opinionated and specific to this workflow.

For full technical detail on layout, wiring, and edge cases, refer to the source files and scripts in this repo.
