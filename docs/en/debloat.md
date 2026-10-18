# System Debloat

Core rule: **do not delete read-only system components; disable unnecessary launchd services instead**.

## Before you start

- Back up.
- Run a dry-run:
  ```bash
  sudo ./scripts/m1-optimizer.sh --dry-run --wizard
  ```
- Apply one feature group at a time, reboot, and observe for 24 hours.
- Do not run `--stop` over Screen Sharing.

## Interactive optimizer

The supported entry point is:

```bash
sudo ./scripts/m1-optimizer.sh
```

Modes:

- **Wizard**: asks one question at a time.
- **Custom**: toggle feature groups.
- **Rollback**: restore recorded changes.

Logs:

```text
~/Library/Logs/M1-Air-Forever/optimizer-YYYYmmdd-HHMMSS.log
```

## Feature groups

| Group | Disables | Cost |
|---|---|---|
| Telemetry | diagnostics, crash reports, ads | No diagnostics upload |
| CoreDuet | device learning, prediction | Less context learning |
| Siri | `com.apple.Siri.agent` | Siri off; dictation remains |
| Widgets | `chronod` | Desktop widgets stop |
| Spotlight | Spotlight indexing and mdworker | Search broken |
| Sharing | AirDrop, Handoff, Screen Sharing, SMB/SSH | Sharing broken |
| iCloud | cloud sync and photo analysis | iCloud sync broken |
| Time Machine | backups | No local Time Machine |
| Quick Look | previews and thumbnails | Finder previews broken |
| Find My | Find My services | Find My broken |
| Third-party | OneDrive, ToDesk, updaters, net disks | Those backgrounds stop |

## Rollback

```bash
sudo ./scripts/m1-optimizer.sh --rollback
```

The optimizer records launchd labels and high-level actions in:

```text
~/Library/Application Support/M1-Air-Forever/state.tsv
```

## Wallpaper and Computer Use

- Keep `com.apple.wallpaper.agent` enabled.
- Dynamic lock screen needs `com.apple.wallpaper.extension.video`.
- Computer Use / ReplayKit can leave `replayd` at high CPU; see [known-issues.md](known-issues.md).

## Do not disable

- WindowServer
- Finder
- cfprefsd
- mDNSResponder
- configd
- kernel_task
