<div align="center">

<h1>M1-Air-Forever</h1>

**A 20-year usage plan for MacBook Air M1 2020 / 8GB**

[![License: MIT](https://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat-square)](LICENSE)

**English** | [简体中文](docs/zh-CN/README.md)

</div>

## What this is

M1-Air-Forever is a practical maintenance and optimization guide for keeping a MacBook Air M1 2020 with 8GB unified memory useful for as long as possible.

It focuses on:

- choosing the right macOS version from macOS 11 to macOS 15;
- trimming unnecessary background services without deleting system components;
- reducing RAM pressure and swap wear;
- selecting lightweight software;
- maintaining the battery, SSD and data for a 20-year lifecycle.

This is not a magic 8GB-to-64GB project. It is a long-term plan: fewer background jobs, lighter software, better version choices and measurable trade-offs.

## Quick recommendations

| Area | Recommendation |
|---|---|
| Daily balance | macOS 13 Ventura |
| Security-first | macOS 15 Sequoia + debloat |
| Offline / lightest | macOS 12 Monterey |
| Avoid for daily use | macOS 11 Big Sur |
| RAM savings | Static wallpaper, no Spotlight/Sharing/iCloud/telemetry, lightweight browser |
| Long-term health | Replace battery every 3–5 years, control swap, keep 10–20% disk free |

## Author projects

- Flameshot legacy builds: Flameshot for macOS 11+ / Apple Silicon arm64  
  <https://github.com/alkaid-ops/flameshot-legacy-builds>

## Interactive optimizer

The main entry point is a single interactive script:

```bash
git clone https://github.com/alkaid-ops/M1-Air-Forever.git
cd M1-Air-Forever
sudo ./scripts/m1-optimizer.sh
```

Modes:

```bash
sudo ./scripts/m1-optimizer.sh --wizard     # step-by-step questions
sudo ./scripts/m1-optimizer.sh --custom     # toggle feature groups
sudo ./scripts/m1-optimizer.sh --rollback   # restore recorded changes
sudo ./scripts/m1-optimizer.sh --dry-run    # log only, execute nothing
```

The script logs every action to:

```text
~/Library/Logs/M1-Air-Forever/optimizer-YYYYmmdd-HHMMSS.log
```

### Wizard mode

Wizard mode asks one question at a time:

```text
Keep Spotlight search and indexing? [Y/n]
Keep AirDrop, Handoff and Screen Sharing? [Y/n]
Keep Time Machine backups? [Y/n]
```

If you answer `n`, that feature group is recorded and disabled.

### Custom mode

Custom mode shows a toggle list:

```text
1) [disable] Telemetry, diagnostics and ads
2) [keep]    CoreDuet device learning
3) [keep]    Siri assistant
...
```

Toggle the numbers you want, then apply. `d` runs a dry-run and `q` quits.

## macOS version matrix

| Version | 8GB feel | Security | Modern apps | Recommendation |
|---|---|---|---|---|
| macOS 11 Big Sur | Very light | EOL | Poor | Offline/archive only |
| macOS 12 Monterey | Very light | EOL | Fair | Offline/secondary |
| macOS 13 Ventura | Light | Near EOL | Good | **Daily balance** |
| macOS 14 Sonoma | Heavy | Longer | Good | Use with debloat |
| macOS 15 Sequoia | Heaviest | Longest | Best | Security-first + debloat |

Read more: [macOS versions](docs/en/macos-versions.md)

## RAM optimization

Measured wallpaper RSS on this class of machine:

| Wallpaper | RSS |
|---|---:|
| Dynamic desktop + lock screen | ~147MB active |
| Static Sonoma image | ~84MB settled |
| Static solid color | Usually lower |

Other rules:

- Do not disable memory compression on an 8GB Mac.
- Trim Spotlight, sharing, iCloud, telemetry and widgets first.
- Keep browsers under control; Chrome is usually the largest variable.
- Use static wallpapers unless you are plugged in and need the animation.
- Computer Use / ReplayKit has a known `replayd` high-CPU bug; see [known issues](docs/en/known-issues.md).

Read more: [RAM optimization](docs/en/ram-optimization.md)

## Software recommendations

| Tool | Purpose | Link |
|---|---|---|
| Rectangle | Window management | <https://rectangleapp.com/> |
| Shottr | Screenshots and annotation | <https://shottr.cc/> |
| Flameshot legacy builds | macOS 11+ screenshots | <https://github.com/alkaid-ops/flameshot-legacy-builds> |
| LocalSend | Local file transfer | <https://localsend.org/> |
| KeepingYouAwake | Prevent sleep | <https://keepingyouawake.app/> |
| Clash Verge | Network proxy | <https://github.com/clash-verge-rev/clash-verge-rev> |
| Sogou Input | Chinese input | Official download |

Read more: [software](docs/en/software.md)

## 20-year plan

| Phase | System | Purpose |
|---|---|---|
| 2026–2030 | macOS 13/14/15 | Main machine |
| 2031–2035 | Last secure macOS | Secondary/offline |
| 2036–2040 | Asahi Linux / offline macOS | Documents, media, terminal |
| 2041–2046 | Offline system image | Archive/retro |

Read more: [20-year plan](docs/en/20-year-plan.md)

## Repository layout

```text
.
├── README.md
├── CONTRIBUTING.md
├── LICENSE
├── .github/
│   └── workflows/
├── docs/
│   ├── images/
│   ├── en/
│   └── zh-CN/
└── scripts/
    ├── m1-optimizer.sh
    ├── set-wallpaper.py
    ├── chrome/
    └── legacy/
```

## Safety

- Read the script before running it.
- `launchctl` changes require `sudo` for system services.
- The script records changes and supports rollback.
- Disabling system services may break features you use.
- Do not delete `/System` components.

## Contributing

Issues and pull requests are welcome. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT
