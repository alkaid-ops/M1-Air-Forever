#!/bin/zsh

set -euo pipefail

# Safe residual Apple background cleanup for this Sonoma install.
# This intentionally excludes XProtect, Rosetta, backgroundtaskmanagementd
# and memory-compression boot arguments.

# Wallpaper safety notes:
# - Keep com.apple.wallpaper.agent enabled. Disabling it black-screens the
#   desktop and lock screen.
# - Keep com.apple.wallpaper.extension.video enabled for the Sonoma dynamic
#   lock-screen wallpaper. Disabling or ignoring it (pluginkit) or killing it
#   can black-screen the lock screen.
# - WallpaperAgent rewrites SystemWallpaperURL back to the built-in
#   Sonoma Horizon.mov. For a persistent static lock screen, set it in
#   System Settings instead of editing preferences directly.
# - Restore the dynamic lock-screen wallpaper:
#     pluginkit -e use -i com.apple.wallpaper.extension.video
#     launchctl kickstart -k gui/$(id -u)/com.apple.wallpaper.agent
# - For a static lock-screen wallpaper, set it in System Settings; do not
#   disable the video extension.

# Measured wallpaper RSS on this machine:
# - fully dynamic desktop + lock screen (Sonoma video): ~147 MB active
# - static Sonoma.heic desktop + lock screen:          ~84 MB settled
#   (RSS can temporarily read 100-134 MB while WallpaperAgent/ImageExtension
#    is rebuilding; wait ~20-30 seconds before comparing.)
# - the earlier ~54 MB reading was an idle/incomplete snapshot and is not a
#   valid full-state comparison.
# - a static system solid color may go slightly lower (~70-90 MB); a persisted
#   static lock screen must be set in System Settings.

MODE="dry-run"
DO_STOP=0
DO_USER=1
DO_SYSTEM=1

usage() {
  cat <<'EOF'
Usage:
  ./disable-apple-residual.sh [--dry-run]
  ./disable-apple-residual.sh --apply [--stop] [--user-only|--system-only]
  ./disable-apple-residual.sh --enable [--user-only|--system-only]

Options:
  --dry-run      Print actions without changing launchd (default).
  --apply        Disable the curated residual services.
  --enable       Re-enable the curated residual services.
  --stop         Also boot out currently loaded services.
  --user-only    Only handle gui/<uid> services.
  --system-only  Only handle system services.
  --help         Show this help.

Effects:
  Disables CoreDuet context learning, diagnostics/telemetry, ad agents and the
  widget timeline agent (chronod).
  WallpaperAgent is kept enabled because desktop and lock-screen wallpaper need it.
  Siri and dictation keep working.
EOF
}

while (( $# > 0 )); do
  case "$1" in
    --dry-run) MODE="dry-run" ;;
    --apply) MODE="apply" ;;
    --enable) MODE="enable" ;;
    --stop) DO_STOP=1 ;;
    --user-only) DO_SYSTEM=0 ;;
    --system-only) DO_USER=0 ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 2 ;;
  esac
  shift
done

UID_NUM="$(id -u)"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$HOME/Library/Application Support/codex-apple-residual"

USER_LABELS=(
  com.apple.ContextStoreAgent
  com.apple.diagnostics_agent
  com.apple.diagnosticextensionsd
  com.apple.spindump_agent
  com.apple.ReportCrash
  com.apple.ap.adprivacyd
  com.apple.ap.promotedcontentd
  com.apple.chronod
)

SYSTEM_LABELS=(
  com.apple.coreduetd
  com.apple.contextstored
  com.apple.dprivacyd
  com.apple.symptomsd-diag
  com.apple.spindump
  com.apple.awdd
  com.apple.rtcreportingd
)

backup_state() {
  mkdir -p "$BACKUP_DIR"
  launchctl print-disabled "gui/$UID_NUM" > "$BACKUP_DIR/disabled-gui-$STAMP.txt" 2>/dev/null || true
  if (( DO_SYSTEM )); then
    sudo launchctl print-disabled system > "$BACKUP_DIR/disabled-system-$STAMP.txt" 2>/dev/null || true
  fi
}

set_user_state() {
  local label="$1"

  if [[ "$MODE" == "dry-run" ]]; then
    printf '  launchctl disable gui/%s/%s\n' "$UID_NUM" "$label"
    if (( DO_STOP )); then
      printf '  launchctl bootout gui/%s/%s\n' "$UID_NUM" "$label"
    fi
    return
  fi

  if [[ "$MODE" == "enable" ]]; then
    launchctl enable "gui/$UID_NUM/$label" 2>/dev/null || true
    return
  fi

  launchctl disable "gui/$UID_NUM/$label" 2>/dev/null || true
  if (( DO_STOP )); then
    launchctl bootout "gui/$UID_NUM/$label" 2>/dev/null || true
  fi
}

set_system_state() {
  local label="$1"

  if [[ "$MODE" == "dry-run" ]]; then
    printf '  sudo launchctl disable system/%s\n' "$label"
    if (( DO_STOP )); then
      printf '  sudo launchctl bootout system/%s\n' "$label"
    fi
    return
  fi

  if [[ "$MODE" == "enable" ]]; then
    sudo launchctl enable "system/$label" 2>/dev/null || true
    return
  fi

  sudo launchctl disable "system/$label" 2>/dev/null || true
  if (( DO_STOP )); then
    sudo launchctl bootout "system/$label" 2>/dev/null || true
  fi
}

if [[ "$MODE" != "dry-run" ]]; then
  if (( DO_SYSTEM )); then
    sudo -v
  fi
  backup_state
fi

if (( DO_USER )); then
  echo
  echo "User residual services:"
  for label in "${USER_LABELS[@]}"; do
    set_user_state "$label"
  done
fi

if (( DO_SYSTEM )); then
  echo
  echo "System residual services:"
  for label in "${SYSTEM_LABELS[@]}"; do
    set_system_state "$label"
  done
fi

if [[ "$MODE" == "dry-run" ]]; then
  echo
  echo "Apply locally with: ./disable-apple-residual.sh --apply --stop"
  echo "Restore with:      ./disable-apple-residual.sh --enable"
fi
