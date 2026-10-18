#!/bin/zsh

set -euo pipefail

# Disable non-allowlisted third-party launchd jobs on this Mac.
# Apple system services are intentionally excluded.
# The default mode is dry-run. Use --apply to change launchd state.

MODE="dry-run"
DO_ENABLE=0
DO_STOP=0
DO_USER=1
DO_SYSTEM=1

usage() {
  cat <<'EOF'
Usage:
  ./disable-extra-launchd.sh [--dry-run]
  ./disable-extra-launchd.sh --apply [--stop] [--user-only|--system-only]
  ./disable-extra-launchd.sh --enable [--user-only|--system-only]

Options:
  --dry-run      Print actions without changing launchd (default).
  --apply        Persistently disable the listed third-party jobs.
  --enable       Re-enable the listed jobs.
  --stop         Also boot out currently loaded jobs. Run locally, not over remote control.
  --user-only    Only handle gui/<uid> jobs.
  --system-only  Only handle system jobs.
  --help         Show this help.
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
BACKUP_DIR="$HOME/Library/Application Support/codex-launchd-cleanup"

USER_LABELS=(
  com.youqu.todesk.client.startup
  com.youqu.todesk.desktop
  com.microsoft.SyncReporter
  com.microsoft.OneDriveStandaloneUpdater
  com.microsoft.update.agent
  com.oray.sunlogin.desktopagent
  com.oray.sunlogin.client.startup
  org.pqrs.karabiner.NotificationWindow
  org.pqrs.karabiner.agent.karabiner_grabber
  org.pqrs.karabiner.agent.karabiner_observer
  org.pqrs.karabiner.karabiner_console_user_server
  org.pqrs.karabiner.karabiner_session_monitor
  pro.betterdisplay.BetterDisplayHelper
  com.google.keystone.agent
  com.google.keystone.xpcservice
  com.google.GoogleUpdater.wake
  netdisk_service
  com.carriez.RustDesk_server
)

SYSTEM_LABELS=(
  com.canonical.multipassd
  com.disable.softwareupdate
  com.microsoft.OneDriveStandaloneUpdaterDaemon
  com.microsoft.OneDriveUpdaterDaemon
  com.microsoft.autoupdate.helper
  com.microsoft.office.licensingV2.helper
  com.oray.sunlogin.helper
  com.oray.sunlogin.service
  com.rogueamoeba.aceagent.label
  com.rogueamoeba.acetool.label
  com.youqu.todesk.UninstallerHelper
  com.youqu.todesk.UninstallerWatcher
  com.youqu.todesk.service
  netbird
  org.pqrs.Karabiner-DriverKit-VirtualHIDDeviceClient
  org.pqrs.karabiner.karabiner_grabber
  org.pqrs.karabiner.karabiner_observer
)

LOGIN_ITEMS_TO_REMOVE=(
  "NetBar"
  "CopyClip"
  "Android File Transfer Agent"
)

print_command() {
  printf '  %s\n' "$*"
}

backup_state() {
  mkdir -p "$BACKUP_DIR"
  launchctl print-disabled "gui/$UID_NUM" > "$BACKUP_DIR/disabled-gui-$STAMP.txt" 2>/dev/null || true
  if (( DO_SYSTEM )); then
    sudo launchctl print-disabled system > "$BACKUP_DIR/disabled-system-$STAMP.txt" 2>/dev/null || true
  fi
  printf 'Backup written to: %s\n' "$BACKUP_DIR"
}

handle_user() {
  local label="$1"

  if [[ "$MODE" == "dry-run" ]]; then
    print_command "launchctl disable gui/$UID_NUM/$label"
    if (( DO_STOP )); then
      print_command "launchctl bootout gui/$UID_NUM/$label"
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

handle_system() {
  local label="$1"

  if [[ "$MODE" == "dry-run" ]]; then
    print_command "sudo launchctl disable system/$label"
    if (( DO_STOP )); then
      print_command "sudo launchctl bootout system/$label"
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

remove_login_items() {
  local item
  for item in "${LOGIN_ITEMS_TO_REMOVE[@]}"; do
    if [[ "$MODE" == "dry-run" ]]; then
      print_command "remove login item: $item"
      continue
    fi
    if [[ "$MODE" == "apply" ]]; then
      osascript -e "tell application \"System Events\" to delete login item \"$item\"" >/dev/null 2>&1 || true
    fi
  done
}

if [[ "$MODE" == "dry-run" ]]; then
  echo "DRY RUN: no launchd state will be changed."
else
  if (( DO_SYSTEM )); then
    sudo -v
  fi
  backup_state
fi

if (( DO_USER )); then
  echo
  echo "User launchd jobs:"
  for label in "${USER_LABELS[@]}"; do
    handle_user "$label"
  done
fi

if (( DO_SYSTEM )); then
  echo
  echo "System launchd jobs:"
  for label in "${SYSTEM_LABELS[@]}"; do
    handle_system "$label"
  done
fi

if (( DO_USER )); then
  echo
  echo "Login items:"
  remove_login_items
fi

if [[ "$MODE" == "dry-run" ]]; then
  echo
  echo "Run locally with: ./disable-extra-launchd.sh --apply --stop"
  echo "Restore state with: ./disable-extra-launchd.sh --enable"
fi
