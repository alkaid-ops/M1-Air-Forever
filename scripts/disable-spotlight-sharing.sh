#!/bin/zsh

set -euo pipefail

# Disable Spotlight indexing/search and macOS sharing services.
# This is intentionally separate from third-party launchd cleanup.
# The default mode is dry-run.

MODE="dry-run"
DO_STOP=0
DO_USER=1
DO_SYSTEM=1

usage() {
  cat <<'EOF'
Usage:
  ./disable-spotlight-sharing.sh [--dry-run]
  ./disable-spotlight-sharing.sh --apply [--stop] [--user-only|--system-only]
  ./disable-spotlight-sharing.sh --enable [--user-only|--system-only]

Options:
  --dry-run      Print actions without changing launchd (default).
  --apply        Disable Spotlight and sharing services.
  --enable       Re-enable them.
  --stop         Also boot out currently loaded services.
  --user-only    Only handle gui/<uid> services.
  --system-only  Only handle system services.
  --help         Show this help.

Notes:
  --stop ends Screen Sharing, AirDrop/Handoff, Spotlight and related user agents.
  Run locally, not over Screen Sharing, if you still use it.
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
BACKUP_DIR="$HOME/Library/Application Support/codex-spotlight-sharing"

USER_LABELS=(
  com.apple.Spotlight
  com.apple.corespotlightd
  com.apple.spotlightknowledged
  com.apple.sharingd
  com.apple.rapportd
  com.apple.AirPlayUIAgent
  com.apple.amp.mediasharingd
  com.apple.mediastream.mstreamd
  com.apple.sidecar-relay
  com.apple.screensharing.agent
  com.apple.screensharing.menuextra
  com.apple.RapportUIAgent
  com.apple.screensharing.MessagesAgent
)

SYSTEM_LABELS=(
  com.apple.metadata.mds
  com.apple.metadata.mds.index
  com.apple.metadata.mds.scan
  com.apple.metadata.mds.spindump
  com.apple.rapportd
  com.apple.AirPlayXPCHelper
  com.apple.screensharing
  com.apple.smbd
  com.apple.RemoteDesktop.PrivilegeProxy
  com.openssh.sshd
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
  if [[ "$MODE" == "apply" ]]; then
    sudo mdutil -a -i off >/dev/null 2>&1 || true
  fi
fi

if [[ "$MODE" == "dry-run" ]]; then
  echo
  echo "Spotlight indexing:"
  echo "  sudo mdutil -a -i off"
fi

if (( DO_USER )); then
  echo
  echo "User Spotlight/Sharing services:"
  for label in "${USER_LABELS[@]}"; do
    set_user_state "$label"
  done
fi

if (( DO_SYSTEM )); then
  echo
  echo "System Spotlight/Sharing services:"
  for label in "${SYSTEM_LABELS[@]}"; do
    set_system_state "$label"
  done
fi

if [[ "$MODE" == "enable" ]] && (( DO_SYSTEM )); then
  sudo mdutil -a -i on >/dev/null 2>&1 || true
fi

if [[ "$MODE" == "dry-run" ]]; then
  echo
  echo "Apply locally with: ./disable-spotlight-sharing.sh --apply --stop"
  echo "Restore with:      ./disable-spotlight-sharing.sh --enable"
fi
