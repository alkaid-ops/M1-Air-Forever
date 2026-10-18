# M1-Air-Forever

A 20-year usage plan for MacBook Air M1 2020 / 8GB.

[简体中文](../../README.md) | **English**

The goal is not to run the newest heavy software. The goal is to keep this machine low-background, low-RAM, low-swap and low-lag within macOS 11–15 while still running heavy software selectively when needed.

---

## Core principles

- **Use macOS 11–15 or Linux.** Newer macOS releases can leave only about 2GB of available RAM on an 8GB M1, causing memory pressure, swap and lag.
- **Disable unused system services; do not delete system components.**
- **Software selection targets:**
  - Background RAM ≤100MB, foreground app RAM ≤300MB
  - Prefer Rust / C++ / C; second tier: Go / Zig / Swift
  - Avoid WebView / Electron unless there is no alternative
  - Prefer cross-platform tools that work on both macOS and Linux
- Replace the battery only when health is low or runtime no longer meets your needs.

---

## macOS 11–15

| Version | 8GB feel | Security | Modern apps | Recommendation |
|---|---|---|---|---|
| macOS 11 Big Sur | Very light | EOL | Poor | Upgrade to macOS 12 |
| macOS 12 Monterey | Very light | EOL | Fair | Max performance |
| macOS 13 Ventura | Light | Near EOL | Good | **Daily balance** |
| macOS 14 Sonoma | Heavy | Longer | Good | Debloat |
| macOS 15 Sequoia | Heaviest | Longest | Best | Debloat |

Recommendations:

- Daily main machine: macOS 13 Ventura
- Offline / lightest: macOS 12 Monterey
- Current test environment: macOS 14 Sonoma
- Not recommended: macOS 11 as a long-term main system

> PS: I do not want to downgrade; I currently use macOS 14 and this repository is based on macOS 14 testing.

---

## 20-year plan

| Phase | System | Use case | Focus |
|---|---|---|---|
| 2026–2030 | macOS 13/14/15 | Main machine | Low RAM, low swap, low background |
| 2031–2035 | Last secure macOS | Secondary/offline | Freeze system, keep maintaining |
| 2036–2040 | Asahi Linux / offline macOS | Documents, media, terminal | Verify hardware support |
| 2041–2046 | Offline system image | Archive/retro | Data readable, hardware repairable |

Battery:

- Replace only when health is low or runtime is insufficient.
- Limit charge to 70–80% when always plugged in.
- Avoid long periods of heat + full charge.

---

## Low-RAM software goal

Targets:

- Background RAM ≤100MB
- Foreground app RAM ≤300MB
- Avoid WebView / Electron where possible
- Prefer native GUI or TUI/CLI

Language priority:

| Tier | Languages | Notes |
|---|---|---|
| Tier 1 | Rust, C++, C | Native memory layout, small binaries, predictable runtime |
| Tier 2 | Go, Zig, Swift | Good performance; Go has GC, Zig/Swift are native |
| Tier 3 | Python, Lua, shell | Good for tools, not for long-running GUI |
| Avoid by default | Electron, WebView-heavy apps, JVM GUI | Large baseline memory |

AI-assisted build direction:

- Release builds, LTO, strip, disable unused features.
- Reduce dynamic WebView/Electron runtimes.
- Prefer system libraries; avoid duplicate packaging.
- On Linux, prefer distribution packages first; build only when necessary.

---

## System debloat: interactive script

Single entry point:

```bash
sudo ./scripts/m1-optimizer.sh
```

Modes:

```bash
sudo ./scripts/m1-optimizer.sh --wizard     # step-by-step questions
sudo ./scripts/m1-optimizer.sh --custom     # toggle feature groups
sudo ./scripts/m1-optimizer.sh --rollback   # restore recorded changes
sudo ./scripts/m1-optimizer.sh --dry-run    # log only, execute nothing
```

Logs:

```text
~/Library/Logs/M1-Air-Forever/optimizer-YYYYmmdd-HHMMSS.log
```

Feature groups:

| Group | Disables | Cost |
|---|---|---|
| Telemetry/ads | diagnostics, crash reports, ads | No diagnostics upload |
| CoreDuet | device learning, prediction | Less cross-device context |
| Siri | Siri agent | Siri off; dictation remains |
| Widgets | chronod | Desktop widgets stop |
| Spotlight | indexing, mdworker | Search broken |
| Sharing | AirDrop, Handoff, Screen Sharing, SMB/SSH | Sharing broken |
| iCloud | cloud sync, photo analysis | iCloud sync broken |
| Time Machine | backups | No automatic backups |
| Quick Look | previews, thumbnails | Finder previews broken |
| Find My | Find My services | Find My broken |
| Third-party | OneDrive, ToDesk, updaters, etc. | Those backgrounds stop |

State file:

```text
~/Library/Application Support/M1-Air-Forever/state.tsv
```

Do not disable:

- WindowServer
- Finder
- cfprefsd
- mDNSResponder
- configd
- kernel_task
- `com.apple.wallpaper.agent` (black screen)

---

## RAM optimization

Measure:

```bash
memory_pressure
vm_stat
top -o mem
ps -axo pid,rss,%cpu,comm | sort -k2 -nr | head -20
```

Trim first:

- Spotlight / mdworker
- iCloud / cloudd / bird
- Time Machine
- telemetry, ads, CoreDuet
- Widget timeline
- third-party updaters and cloud disks

8GB rules:

- Do not disable memory compression.
- Do not keep multiple browsers resident.
- Keep 10–20 browser tabs.
- Use dynamic wallpaper only while plugged in or for demos.
- Static Sonoma wallpaper is about 84MB settled; dynamic desktop + lock screen is about 147MB active.
- Keep 10–20% disk free.

---

## Software recommendations

Keep:

- Rectangle: window management
- Shottr: screenshots
- Flameshot legacy builds: macOS 11+ screenshots, maintained by the author  
  <https://github.com/alkaid-ops/flameshot-legacy-builds>
- LocalSend: local file transfer
- KeepingYouAwake: prevent sleep
- Clash Verge / Mihomo: network proxy
- Sogou Input; Linux: Fcitx5 + Rime

Cross-platform first:

| Category | macOS | Linux | Language/runtime |
|---|---|---|---|
| Terminal | WezTerm / Alacritty / Ghostty | WezTerm / Alacritty / Ghostty | Rust / Zig |
| Editor | Helix / Neovim / Zed | Helix / Neovim / Zed | Rust / C / Rust |
| Browser | Firefox / Safari / Orion | Firefox / Chromium | Rust / C++ |
| Media | IINA / mpv | mpv / VLC | C / C++ |
| Screenshot | Shottr / Flameshot | Flameshot | C++/Qt |
| File manager | Finder / Yazi | Nautilus / Dolphin / Yazi | Native / Rust |
| Notes | Apple Notes / Markdown + Neovim | Markdown + Neovim / Zettlr | C/Rust |
| Sync | Syncthing / LocalSend | Syncthing / LocalSend | Go / Flutter |
| Input method | Squirrel/Rime | Fcitx5 + Rime | C++ |
| PDF | Skim / Sioyek / Zathura | Sioyek / Zathura / Okular | C/C++ |
| Proxy | Mihomo + Clash Verge | Mihomo + Clash Verge | Go / Tauri |

Avoid resident bloat:

- Multiple cloud sync clients
- Adobe Creative Cloud background
- Multiple browsers at once
- Game launchers
- Auto-updaters
- Desktop widget suites

---

## Linux plan

Recommended distributions:

| Distribution | Package family | Why | Notes |
|---|---|---|---|
| Fedora Asahi Remix | RPM | Official Asahi Linux distribution | Best hardware support |
| Debian Asahi | DEB | Stable and small | Support may lag |
| Ubuntu Asahi | DEB | Familiar desktop | Verify current M1 Air support |

Do not use Arch / Manjaro or other rolling distributions.

Verify before switching:

- Wi-Fi / Bluetooth
- microphone
- speaker DSP
- GPU acceleration
- webcam
- suspend/resume
- Touch ID
- Thunderbolt/USB-C
- external displays

Linux alternatives:

| macOS | Linux |
|---|---|
| Safari | Firefox |
| Shottr | Flameshot |
| IINA | mpv |
| Rectangle | Sway/Hyprland tiling |
| KeepingYouAwake | systemd-inhibit |
| Squirrel/Rime | Fcitx5 + Rime |
| Skim | Zathura / Sioyek |
| Apple Notes | Markdown + Neovim |

---

## Known issues

Computer Use / ReplayKit:

- `replayd` can sit at 70–90% CPU while idle.
- Issue: <https://github.com/openai/codex/issues/37420>

Temporary mitigation:

```bash
pkill -x SkyComputerUseService
```

More drastic, disables Computer Use until reauthorized:

```bash
tccutil reset ScreenCapture com.openai.sky.CUAService
```

---

## Repository structure

```text
.
├── README.md
├── LICENSE
├── docs/
│   └── en/
│       └── README.md
└── scripts/
    ├── m1-optimizer.sh
    ├── set-wallpaper.py
    └── chrome/
        ├── ChromeOptimized-Info.plist
        └── chrome-optimized-runner
```

---

## License

MIT

---

## Disclaimer

The scripts, configuration and documentation in this project are provided for reference only. Use them at your own risk.

- Disabling system services, changing launchd, wallpaper settings or Chrome flags, or switching to Linux may break features, cause data loss, prevent boot, remove security updates or void support.
- Disabling SIP, Gatekeeper or FileVault reduces system security.
- This project is not affiliated with Apple, OpenAI, Flameshot or their projects.
- The authors are not responsible for any direct or indirect damage.
- Back up your data first, test in a VM or non-primary machine, and keep a rollback plan.
