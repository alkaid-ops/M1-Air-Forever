# 20-Year Plan

Apple will not support one M1 for 20 years. The goal is to keep the machine useful, repairable and data-portable.

## Phases

| Phase | System | Purpose | Focus |
|---|---|---|---|
| 2026–2028 | macOS 13/14/15 | Main machine | Debloat, lightweight apps, battery |
| 2029–2031 | Last secure macOS | Main/secondary | Freeze upgrades, annual cleanup |
| 2032–2035 | Frozen macOS | Office/media/remote | Battery replacement, backups |
| 2036–2040 | Asahi Linux / offline macOS | Documents/media/terminal | Repairs, offline data |
| 2041–2046 | Offline image | Archive/retro | Data migration, repair |

## Hardware

### Battery

- Replace every 3–5 years or below 80% health.
- Limit charge to 70–80% if always plugged in.
- Avoid long periods of heat + full charge.

### SSD

- Keep 10–20% free.
- Reduce swap.
- Do not disable memory compression.
- Track disk writes yearly.

### Thermals

- The M1 Air is fanless. Sustained load throttles.
- Avoid blocking the bottom.
- Do not treat compiling, transcoding or local LLMs as daily tasks.

## Software lifecycle

### 2026–2030

- macOS 13/15.
- Run the optimizer.
- Keep only necessary login items.
- Back up annually.

### 2031–2035

- Freeze on the last secure macOS.
- Keep the browser updated.
- Remove unused cloud sync.

### 2036+

- Consider Asahi Linux.
- Keep one offline macOS volume.
- Store data in open formats.

## Data

- 3-2-1 backup.
- One offline archive per year.
- Do not rely on iCloud alone.
- Keep installers and recovery images.

## Annual checklist

- [ ] Battery health / cycles
- [ ] Disk free / SSD health
- [ ] Memory pressure / swap
- [ ] LaunchAgents / login items
- [ ] Browser extensions
- [ ] Software updates
- [ ] Full backup
- [ ] Remove unused resident apps
