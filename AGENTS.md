## Purpose of this repo

- This repo defines the **dev containers and host setup** for your workflow: it builds the `fonzzy1/vim` Docker image and provides `setup` + `runit` to bootstrap the local environment and open containers. Expect Dockerfiles, dotfiles, and scripts rather than a conventional app + test suite.

## How this repo fits the workflow

- On a new machine, the human runs `python3 runit setup --init` on the host once to install GNOME/Kitty/Docker and apply the dotfiles/theme.
- Day to day, the human uses `python3 runit ...` on the host to open a `fonzzy1/vim` container with the current project mounted and Neovim/OpenCode preconfigured.
- Agents should **never** invoke `setup` themselves; treat it as a host-only bootstrap step the user runs explicitly.

## Layout that actually matters

- `Dockerfile` — defines the `fonzzy1/vim:latest` image and installs most tools (R, Python, Node, Rust, Quarto, OpenCode, Neovim, etc.).
- `build` — wrapper script around `docker build`; only rebuilds if `Dockerfile`, `dotfiles/`, `vim/`, or `run_scripts/` changed.
- `dotfiles/` — user environment config copied into the image (bash, OpenCode, feeds, lazygit, marksman, etc.).
  - `dotfiles/.config/opencode/opencode.json` — OpenCode config and permissions for the container.
  - `dotfiles/.config/opencode/agents/` — custom agent configs
  - `dotfiles/.config/opencode/tools/` — custom tools: PDF extraction (`library.ts`), RSS reader (`rss.ts`), and `open.ts`.
  - `dotfiles/feeds/*.opml` — OPML collections used by the RSS tools (e.g. `news`, `academic`, `arxiv`, `pods`).
- `vim/` — Neovim configuration bundled into the image.
  - `vim/vimscript/AI_shortcuts.vim` — Vim `:Summarise` command that shells out to OpenCode to summarise PDFs.
  - `vim/lua/opencode_config.lua` — Neovim integration with the OpenCode plugin.
  - `vim/lua/toggletasks.json` — task definitions used inside Neovim (Quarto, Docker, Python helpers).
- `run_scripts/` — helper scripts copied into `/scripts` inside the image (RSS parsing, podcast downloader, Quarto filters, etc.).
- `runit` — Python entrypoint for running the `fonzzy1/vim` container against host directories and wiring up OpenCode.
- `setup` — **host bootstrap script** for a full GNOME + Kitty + Docker environment; used by the human to set up their machine, not something agents should run.
- `test/test.qmd` — Quarto test document wired to `/scripts/callouts.lua`.

## How to build and run the image

Prefer the repo scripts over ad‑hoc Docker commands; they encode non‑obvious behaviour.

### Building the container

- Normal build path (also exposed via ToggleTasks):
  - `sh ./build`
  - Root `.toggletasks.json` defines a "Run build script" task with this exact command.
- What the script does:
  - Skips the build if **no changes** in `Dockerfile`, `dotfiles/`, `vim/`, or `run_scripts/`.
  - If `DOKER_USER` and `DOCKER_TOKEN` are set, logs into Docker before building.
  - Builds `fonzzy1/vim:latest` from the current directory.
- If you bypass `build` and call `docker build` directly, you must remember the tag yourself; the repo assumes `fonzzy1/vim:latest`.

### Running the container (host workflow context)

These commands are usually run **on the host**, not inside the container, but they explain how this repo is meant to be used:

- Default: mount the **current directory** into a `fonzzy1/vim` container and open Neovim:
  - `python3 runit` (or `python3 runit local`)
  - Optional: `--kitty` opens a separate Kitty window that runs `opencode --port 3000` inside the container.
- Clone and work on a GitHub repo in a container:
  - `python3 runit gh owner/repo` (clones into `~/Documents/owner-repo` on the host, then runs Neovim + OpenCode inside the container).
- Edit this config repo inside its own container:
  - `python3 runit config`
- Podcast workflow:
  - `python3 runit audio` (with optional `--music`) runs `/scripts/podcast_downloader.py` with extra host mounts.
- Host bootstrap (heavy, graphical, and installs system packages):
  - `python3 runit setup --init` → how the human bootstraps a new host; **agents must not run this unless the user explicitly and knowingly asks for host setup**.

## OpenCode configuration & custom tools

- OpenCode config for the container lives in `dotfiles/.config/opencode/opencode.json`:
  - File and bash operations outside `/tmp` generally require explicit permission.
  - Built‑in `build` and `plan` agent features are disabled; rely on your own short written plan instead of UI automation.
- Custom agents (already wired up in the container):
  - `research-assistant.md` — the main RA profile (plan‑first, uses `/tmp` as default scratch, asks before editing project files).
  - `supervisor.md` — strategic reviewer who usually does not edit code.
- Custom tools worth using instead of re‑implementing logic:
  - `PDF read` (`library.ts`) — extracts text from a local PDF via `pdftotext -layout`; use this instead of writing your own PDF parser.
  - `RSS list` / `RSS read` (`rss.ts`) — read curated feeds from `/root/feeds/*.opml` using `/scripts/feed_parser.py`; ideal for quickly pulling recent papers/news/podcasts.
  - `Open` (`open.ts`) — opens URLs/files via `xdg-open` (overridden by `/scripts/open.py`). Use this when the user wants something opened on their side.

## Neovim, Quarto, and testing hooks

- Neovim is the primary editor inside the container; config is opinionated and tightly coupled to this repo.
- The `Summarise` command in Neovim (`:Summarise /path/to/file.pdf`) uses `pdftotext` + OpenCode to generate citation‑style claim lists; if you need article claims, prefer this path instead of ad‑hoc summarisation.
- Quarto tasks are pre‑defined (both in `run_scripts/toggletasks.json` and `vim/lua/toggletasks.json`):
  - `quarto preview ${file}` and `quarto render ${file}` are the expected commands.
  - `test/test.qmd` is a working example wired to `/scripts/callouts.lua` and Python chunks.

## Pitfalls & things to avoid

- Do **not** treat this as a generic app repo: there is no central `package.json`, `pyproject.toml`, or test runner; focus on Dockerfile, Neovim config, dotfiles, and helper scripts.
- Avoid modifying `setup` or running `python3 runit setup --init` unless the user clearly wants system‑level changes on their host and understands the impact.
- When changing anything under `dotfiles/`, `vim/`, or `run_scripts/`, remember that these are **copied into the image** by `Dockerfile`; validate that your changes still make sense in that context (paths, binaries, and environment inside the container).
- When in doubt about how something is wired, check the **scripts first** (`build`, `runit`, `run_scripts/*`) rather than assuming a default workflow.
