# Scripts

## Main entry point

```bash
sudo ./m1-optimizer.sh
```

The optimizer supports:

- Wizard mode: asks one question at a time.
- Custom mode: toggle feature groups.
- Rollback: restores recorded launchd changes.
- Logs: `~/Library/Logs/M1-Air-Forever/optimizer-YYYYmmdd-HHMMSS.log`

```bash
sudo ./m1-optimizer.sh --wizard
sudo ./m1-optimizer.sh --custom
sudo ./m1-optimizer.sh --rollback
sudo ./m1-optimizer.sh --dry-run
```

## Helpers

- `set-wallpaper.py`: set or restore a static wallpaper.
- `chrome/chrome-optimized-runner`: Chrome with a smaller GPU budget.
- `chrome/chrome-low-gpu-runner`: Chrome with GPU disabled.

## Legacy

`legacy/` contains the original split scripts. They are kept for reference; the supported user-facing entry point is `m1-optimizer.sh`.
