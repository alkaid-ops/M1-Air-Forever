# RAM Optimization for 8GB M1

The goal is not to empty memory. It is to reduce sustained background load, swap and SSD wear.

## Measure

```bash
memory_pressure
vm_stat
top -o mem
ps -axo pid,rss,%cpu,comm | sort -k2 -nr | head -20
```

Watch:

- `Pages occupied by compressor`
- `Pageouts`
- free memory percentage
- swap growth

## Rules

1. Do not disable memory compression.
2. Keep browsers under control.
3. Avoid many Electron apps.
4. Do not run dynamic wallpaper + Computer Use + multiple browsers.
5. Keep 10–20% disk free.
6. Use Low Power Mode on battery.

## Background services

Trim first:

- Spotlight / mdworker
- iCloud / cloudd / bird
- Time Machine
- CoreDuet, telemetry, ads
- Widget timeline
- Third-party updaters and cloud disks

Use the interactive optimizer in [debloat.md](debloat.md).

## Browsers

Chrome is usually the largest variable.

- Keep 10–20 active tabs.
- Use `scripts/chrome/chrome-optimized-runner`.
- Use `chrome-low-gpu-runner` only when memory matters more than CPU.
- Reduce extensions.

## Wallpaper measurements

| Setup | Wallpaper RSS |
|---|---:|
| Dynamic desktop + lock screen | ~147MB active |
| Static Sonoma image | ~84MB settled |
| Static solid color | Usually lower |

Prefer static wallpapers.

## Computer Use / ReplayKit

Known issue: `SkyComputerUseService` can drive `replayd` to 70–90% CPU while idle.

Temporary mitigation:

```bash
pkill -x SkyComputerUseService
```

More drastic, disables Computer Use until reauthorized:

```bash
tccutil reset ScreenCapture com.openai.sky.CUAService
```

See [known-issues.md](known-issues.md).

## WindowServer

WindowServer composes the display. Do not kill it.

- High-refresh external displays increase load.
- Dynamic wallpaper, transparency and many animations increase load.

## SSD and swap

- Swap is normal; constant heavy swap is not.
- Do not run large local models, multi-track 4K editing or multiple VMs on 8GB.
- Monitor pageouts and disk writes.
