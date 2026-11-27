# Set up a Codex Cloud environment

Prepare the home directory of the user who will run Codex. Set `source_dir` to the extracted archive root (normally `$HOME/.local/share/chezmoi`), where `.chezmoiexternal.toml` sits alongside `no-deploy/`. Run the commands from the user's project. Keep the source available for future targeted applies.

## Locate chezmoi

Use `command -v chezmoi` to find an existing installation. If installation is needed, prefer the distribution's package when available. For Debian releases without a candidate, use the official release's `.deb` for the machine's architecture. A user-local release binary also works when system installation is unavailable. Set `chezmoi_bin` to the absolute path of the executable and confirm `"$chezmoi_bin" --version` succeeds. [Upstream installation options](https://www.chezmoi.io/install/)

## Deploy the tools and Git preferences

Run this block as the task user with `source_dir` and `chezmoi_bin` set in the same shell.

```bash
set -eu
mkdir -p "$HOME/.local" "$HOME/.config"
"$chezmoi_bin" --source "$source_dir" apply --error-on-conflict \
  "$HOME/.agents" "$HOME/.local/libexec" "$HOME/.config/git"
git config --file "$HOME/.config/git/local-config" core.editor vi
```

The deployed Git config includes `local-config`, so the editor override belongs there. Preserve the user's existing `~/.gitconfig` and the project's settings. If chezmoi reports a conflict, identify the affected path for the user.

## Verify in a fresh task shell

From the original project, run:

```bash
set -eu
test -f "$HOME/.agents/skills/coding-style/SKILL.md"
test -f "$HOME/.agents/skills/sync-coding-style/SKILL.md"
test -x "$HOME/.local/libexec/git-format-message"
command -v vi
git config --show-origin --get core.editor
git config --show-origin --get pull.ff
```

Expect Git to report `vi` and `only`. If a project or user override takes precedence, report the value and its origin. For reusable environments, verify skill discovery in a new Codex task started from the published setup.
