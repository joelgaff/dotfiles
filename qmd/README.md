# QMD — Local Markdown Search

[QMD](https://github.com/nickarrow/qmd) is a local search engine for markdown files. It indexes
collections of markdown documents and provides keyword (BM25), semantic (vector), and hybrid search.

## What's here

This stow package installs a systemd user timer that keeps the QMD index up to date automatically.

| File | Purpose |
|------|---------|
| `qmd-update.service` | Runs `qmd update` (re-scan files) then `qmd embed` (refresh vector embeddings) |
| `qmd-update.timer` | Fires the service daily, 10 minutes after login |

## Setup

### Prerequisites

QMD must be installed first:

```bash
npm install -g @tobilu/qmd
```

And at least one collection must be configured:

```bash
qmd collection add /path/to/your/markdown/folder --name mycollection
qmd embed   # initial embedding (can take a while)
```

### Install the timer

```bash
# From ~/dotfiles, stow the package to create symlinks
cd ~/dotfiles
stow qmd

# Reload systemd to pick up the new files
systemctl --user daemon-reload

# Enable the timer (starts on every login)
systemctl --user enable qmd-update.timer

# Start it now (otherwise it waits for next login)
systemctl --user start qmd-update.timer
```

### Verify it's running

```bash
# Check timer status and next fire time
systemctl --user list-timers qmd-update.timer

# Check last run results
systemctl --user status qmd-update.service

# View logs
journalctl --user -u qmd-update.service
```

### Run manually

```bash
# Trigger an immediate re-index without waiting for the timer
systemctl --user start qmd-update.service
```

### Uninstall

```bash
systemctl --user disable qmd-update.timer
systemctl --user stop qmd-update.timer
cd ~/dotfiles
stow -D qmd
```

## Notes

- QMD is installed via npm through mise (node version manager). The service sets PATH
  explicitly to find the `qmd` binary. If you update the node version in mise, update the
  PATH in `qmd-update.service` to match.
- Embedding timeout is 10 minutes (600s). If you have a very large vault and no GPU, the
  initial embedding may need to be run manually with `qmd embed`.
- For GPU-accelerated embedding, install `vulkan-headers`: `sudo pacman -S vulkan-headers`
