#!/bin/zsh

set -euo pipefail

# Explicitly approved Apple service cleanup:
# Time Machine, Quick Look, Find My and iCloud/background-download/update agents.
#
# These features are intentionally disabled:
# - Time Machine backups
# - Quick Look previews and Finder thumbnails
# - Find My Mac and related Find My services
# - iCloud sync, Keychain cloud sync, App Store downloads and software updates
#
# This does not disable local Keychain, Touch ID, local accounts, networking,
# Bluetooth, DRM or general web browsing.

MODE="dry-run"
DO_STOP=0
DO_USER=1
DO_SYSTEM=1

usage() {
  cat <<'EOF'
Usage:
  ./disable-apple-extra.sh [--dry-run]
  ./disable-apple-extra.sh --apply [--stop] [--user-only|--system-only]
  ./disable-apple-extra.sh --enable [--user-only|--system-only]

Options:
  --dry-run      Print actions without changing launchd (default).
  --apply        Disable the approved Apple service groups.
  --enable       Re-enable them.
  --stop         Also boot out currently loaded services.
  --user-only    Only handle gui/<uid> services.
  --system-only  Only handle system services.
  --help         Show this help.

Effects:
  Time Machine, Quick Look, Find My, iCloud sync and update downloads stop
  working by design. Local files and local Keychain data are not deleted.
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
BACKUP_DIR="$HOME/Library/Application Support/codex-apple-extra"

USER_LABELS=(
  com.apple.TMHelperAgent
  com.apple.quicklook
  com.apple.quicklook.ui.helper
  com.apple.quicklook.ThumbnailsAgent
  com.apple.findmymacmessenger
  com.apple.findmy.findmylocateagent
  com.apple.icloud.findmydeviced.findmydevice-user-agent
  com.apple.icloud.searchpartyuseragent
  com.apple.icloud.fmfd
  com.apple.cloudd
  com.apple.nsurlsessiond
  com.apple.bird
  com.apple.iCloudNotificationAgent
  com.apple.iCloudUserNotifications
  com.apple.appstoreagent
  com.apple.storeaccountd
  com.apple.storedownloadd
  com.apple.cloudphotod
  com.apple.photolibraryd
  com.apple.photoanalysisd
  com.apple.cloudpaird
  com.apple.itunescloudd
  com.apple.cloudsettingssyncagent
  com.apple.protectedcloudstorage.protectedcloudkeysyncing
  com.apple.security.cloudkeychainproxy3
  com.apple.SoftwareUpdateNotificationManager
)

SYSTEM_LABELS=(
  com.apple.backupd
  com.apple.backupd-helper
  com.apple.findmymac
  com.apple.findmymacmessenger
  com.apple.findmy.findmybeaconingd
  com.apple.icloud.findmydeviced
  com.apple.icloud.searchpartyd
  com.apple.cloudd
  com.apple.nsurlsessiond
  com.apple.appstored
  com.apple.softwareupdated
  com.apple.mobile.softwareupdated
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
  echo "User Apple services:"
  for label in "${USER_LABELS[@]}"; do
    set_user_state "$label"
  done
fi

if (( DO_SYSTEM )); then
  echo
  echo "System Apple services:"
  for label in "${SYSTEM_LABELS[@]}"; do
    set_system_state "$label"
  done
fi

if [[ "$MODE" == "dry-run" ]]; then
  echo
  echo "Apply locally with: ./disable-apple-extra.sh --apply --stop"
  echo "Restore with:      ./disable-apple-extra.sh --enable"
fi
