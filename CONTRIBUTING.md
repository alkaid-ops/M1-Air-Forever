# Contributing

Contributions are welcome.

## Issues / 问题

Please include:

- macOS version and build;
- Mac model and RAM;
- whether the issue is about a guide or the optimizer script;
- the optimizer log path:
  ```text
  ~/Library/Logs/M1-Air-Forever/optimizer-YYYYmmdd-HHMMSS.log
  ```

Please remove private paths, account names, tokens and other secrets before posting logs.

## Pull requests / PR

- Keep changes scoped.
- Test shell scripts with:
  ```bash
  bash -n scripts/m1-optimizer.sh
  ```
- Test interactive behavior with `--dry-run` first.
- Keep English and Chinese documentation in sync when behavior changes.

## Do not commit

- passwords or tokens
- personal paths with usernames
- private logs
- generated backup files
