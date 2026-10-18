# macOS Versions: 11–15

This guide is for MacBook Air M1 2020 / 8GB. The goal is not the newest release; it is the release that keeps 8GB comfortable through 2030.

## Recommendation

| Priority | Version | Use case |
|---|---|---|
| Daily balance | macOS 13 Ventura | Best mix of performance, apps and background load |
| Security-first | macOS 15 Sequoia | Longest security support; debloat required |
| Offline / lightest | macOS 12 Monterey | Lowest background load |
| Archive only | macOS 11 Big Sur | Too old for modern software |
| Usable but heavy | macOS 14 Sonoma | Modern features, heavier services |

If you keep one daily system: **macOS 13 + this project's optimizer**.  
If the machine stays online for years: **macOS 15 + optimizer**.

## Matrix

| Version | RAM tendency | Background load | Modern apps | Security | 8GB advice |
|---|---:|---:|---:|---|---|
| macOS 11 Big Sur | Low | Low | Poor | EOL | Offline/archive |
| macOS 12 Monterey | Very low | Low | Fair | EOL | Light/offline |
| macOS 13 Ventura | Low | Medium-low | Good | Near EOL | **Preferred** |
| macOS 14 Sonoma | Medium-high | High | Good | Longer | Debloat required |
| macOS 15 Sequoia | High | High | Best | Longest | Security-first + debloat |

## Notes

### macOS 11 Big Sur

Very light on M1, but modern applications are dropping support. Use it only for offline/archive tasks.

### macOS 12 Monterey

Excellent for 8GB M1. Lower background load than Sonoma/Sequoia. Good for documents, media, remote terminal and secondary use.

### macOS 13 Ventura

The sweet spot. Better app compatibility than Monterey without the heavier Sonoma/Sequoia background load.

### macOS 14 Sonoma

Dynamic wallpaper, widgets and extra services increase idle memory. If you must use it, run the optimizer and prefer static wallpapers.

### macOS 15 Sequoia

Best security and app compatibility in the 11–15 range, but the heaviest. Pair it with strict background management.

## Upgrade and downgrade

- M1 cannot run macOS 10.x. macOS 11 is the floor.
- Apple signing windows expire; downgrades usually require a bootable installer or DFU recovery.
- Major upgrades can reset launchd disable states; re-run the optimizer.
- Back up before upgrading.

## 8GB settings

- Prefer static wallpaper.
- Reduce transparency and motion.
- Enable Low Power Mode on battery.
- Avoid multiple always-on browsers.
- Disable unused Spotlight, sharing, iCloud and widgets.
- Do not disable memory compression.
