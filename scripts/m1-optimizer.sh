#!/bin/bash
#
# M1-Air-Forever interactive optimizer
#
# Modes:
#   ./m1-optimizer.sh                 interactive menu
#   ./m1-optimizer.sh --wizard        ask step by step
#   ./m1-optimizer.sh --custom        toggle feature groups
#   ./m1-optimizer.sh --rollback      restore recorded changes
#   ./m1-optimizer.sh --dry-run ...   log commands without executing them
#
set -u

APP_NAME="M1-Air-Forever"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${HOME}/Library/Logs/${APP_NAME}"
STATE_DIR="${HOME}/Library/Application Support/${APP_NAME}"
LOG_FILE="${LOG_DIR}/optimizer-$(date +%Y%m%d-%H%M%S).log"
STATE_FILE="${STATE_DIR}/state.tsv"

DRY_RUN=0
DEBUG=0
SUDO=""
TARGET_UID=""

mkdir -p "$LOG_DIR" "$STATE_DIR"
touch "$LOG_FILE" "$STATE_FILE"

log() {
  printf '[%s] %s\n' "$(date '+%H:%M:%S')" "$*" | tee -a "$LOG_FILE"
}

die() {
  log "ERROR: $*"
  exit 1
}

run() {
  log "RUN: $*"
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "[dry-run] $*"
    return 0
  fi
  "$@" >>"$LOG_FILE" 2>&1
  local rc=$?
  if [ "$rc" -ne 0 ]; then
    log "WARN rc=$rc: $*"
  fi
  return "$rc"
}

run_show() {
  log "RUN: $*"
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "[dry-run] $*"
    return 0
  fi
  "$@" 2>&1 | tee -a "$LOG_FILE"
  return "${PIPESTATUS[0]}"
}

ask_yes_no() {
  local prompt="$1" default="${2:-y}" answer
  while true; do
    if [ "$default" = "y" ]; then
      read -r -p "${prompt} [Y/n] " answer
      answer="${answer:-y}"
    else
      read -r -p "${prompt} [y/N] " answer
      answer="${answer:-n}"
    fi
    case "$answer" in
      y|Y|yes|YES|是) return 0 ;;
      n|N|no|NO|否) return 1 ;;
    esac
  done
}

record_launchd() {
  [ "$DRY_RUN" -eq 1 ] && return 0
  printf 'launchd\t%s\t%s\n' "$1" "$2" >>"$STATE_FILE"
}

record_action() {
  [ "$DRY_RUN" -eq 1 ] && return 0
  printf 'action\t%s\n' "$1" >>"$STATE_FILE"
}

disable_one() {
  local domain="$1" label="$2"
  local target_domain="$domain"
  [ "$domain" = "gui" ] && target_domain="gui/${TARGET_UID}"
  log "Disable ${target_domain}/${label}"
  record_launchd "$domain" "$label"
  run $SUDO launchctl disable "${target_domain}/${label}"
  run $SUDO launchctl bootout "${target_domain}/${label}" 2>/dev/null || true
}

disable_labels() {
  local domain="$1"
  shift
  local label
  for label in "$@"; do
    disable_one "$domain" "$label"
  done
}

enable_one() {
  local domain="$1" label="$2"
  local target_domain="$domain"
  [ "$domain" = "gui" ] && target_domain="gui/${TARGET_UID}"
  run $SUDO launchctl enable "${target_domain}/${label}"
}

# ---------------------------------------------------------------------------
# Feature groups
# ---------------------------------------------------------------------------

TELEMETRY_USER=(
  com.apple.diagnostics_agent
  com.apple.diagnosticextensionsd
  com.apple.spindump_agent
  com.apple.ReportCrash
  com.apple.ap.adprivacyd
  com.apple.ap.promotedcontentd
)
TELEMETRY_SYSTEM=(com.apple.symptomsd-diag com.apple.spindump com.apple.awdd com.apple.rtcreportingd)

COREDUET_USER=(com.apple.ContextStoreAgent)
COREDUET_SYSTEM=(com.apple.coreduetd com.apple.contextstored com.apple.dprivacyd)

SIRI_USER=(com.apple.Siri.agent)
WIDGETS_USER=(com.apple.chronod)

SPOTLIGHT_USER=(com.apple.Spotlight com.apple.corespotlightd com.apple.spotlightknowledged)
SPOTLIGHT_SYSTEM=(com.apple.metadata.mds com.apple.metadata.mds.index com.apple.metadata.mds.scan com.apple.metadata.mds.spindump)

SHARING_USER=(
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
SHARING_SYSTEM=(
  com.apple.rapportd
  com.apple.AirPlayXPCHelper
  com.apple.screensharing
  com.apple.smbd
  com.apple.RemoteDesktop.PrivilegeProxy
  com.openssh.sshd
)

ICLOUD_USER=(
  com.apple.cloudd
  com.apple.bird
  com.apple.iCloudNotificationAgent
  com.apple.iCloudUserNotifications
  com.apple.cloudphotod
  com.apple.photolibraryd
  com.apple.photoanalysisd
  com.apple.cloudpaird
  com.apple.itunescloudd
  com.apple.cloudsettingssyncagent
  com.apple.protectedcloudstorage.protectedcloudkeysyncing
  com.apple.security.cloudkeychainproxy3
)
ICLOUD_SYSTEM=(com.apple.cloudd com.apple.icloud.findmydeviced com.apple.icloud.searchpartyd)

TIMEMACHINE_USER=(com.apple.TMHelperAgent)
TIMEMACHINE_SYSTEM=(com.apple.backupd com.apple.backupd-helper)

QUICKLOOK_USER=(com.apple.quicklook com.apple.quicklook.ui.helper com.apple.quicklook.ThumbnailsAgent)

FINDMY_USER=(
  com.apple.findmymacmessenger
  com.apple.findmy.findmylocateagent
  com.apple.icloud.findmydeviced.findmydevice-user-agent
  com.apple.icloud.searchpartyuseragent
  com.apple.icloud.fmfd
)
FINDMY_SYSTEM=(com.apple.findmymac com.apple.findmy.findmybeaconingd com.apple.icloud.findmydeviced com.apple.icloud.searchpartyd)

THIRDPARTY_USER=(
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
THIRDPARTY_SYSTEM=(
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

FEATURE_KEYS=(telemetry coreduet siri widgets spotlight sharing icloud timemachine quicklook findmy thirdparty)
FEATURE_EN=(
  "Telemetry, diagnostics and ads"
  "CoreDuet device learning"
  "Siri assistant"
  "Desktop widgets"
  "Spotlight search and indexing"
  "AirDrop, Handoff and Screen Sharing"
  "iCloud sync"
  "Time Machine backups"
  "Quick Look previews and thumbnails"
  "Find My"
  "Third-party background jobs"
)
FEATURE_ZH=(
  "遥测、诊断和广告"
  "CoreDuet 设备感知"
  "Siri 语音助手"
  "桌面小组件"
  "Spotlight 搜索和索引"
  "隔空投送、接力和屏幕共享"
  "iCloud 同步"
  "Time Machine 备份"
  "Quick Look 预览和缩略图"
  "查找 Mac"
  "第三方后台常驻"
)

apply_feature() {
  local key="$1"
  log "Apply feature: ${key}"
  case "$key" in
    telemetry)
      disable_labels gui "${TELEMETRY_USER[@]}"
      disable_labels system "${TELEMETRY_SYSTEM[@]}"
      ;;
    coreduet)
      disable_labels gui "${COREDUET_USER[@]}"
      disable_labels system "${COREDUET_SYSTEM[@]}"
      ;;
    siri)
      disable_labels gui "${SIRI_USER[@]}"
      ;;
    widgets)
      disable_labels gui "${WIDGETS_USER[@]}"
      ;;
    spotlight)
      disable_labels gui "${SPOTLIGHT_USER[@]}"
      disable_labels system "${SPOTLIGHT_SYSTEM[@]}"
      record_action spotlight_on
      run $SUDO mdutil -a -i off
      ;;
    sharing)
      disable_labels gui "${SHARING_USER[@]}"
      disable_labels system "${SHARING_SYSTEM[@]}"
      ;;
    icloud)
      disable_labels gui "${ICLOUD_USER[@]}"
      disable_labels system "${ICLOUD_SYSTEM[@]}"
      ;;
    timemachine)
      disable_labels gui "${TIMEMACHINE_USER[@]}"
      disable_labels system "${TIMEMACHINE_SYSTEM[@]}"
      record_action timemachine_on
      run $SUDO tmutil disable
      run $SUDO tmutil stopbackup
      ;;
    quicklook)
      disable_labels gui "${QUICKLOOK_USER[@]}"
      ;;
    findmy)
      disable_labels gui "${FINDMY_USER[@]}"
      disable_labels system "${FINDMY_SYSTEM[@]}"
      ;;
    thirdparty)
      disable_labels gui "${THIRDPARTY_USER[@]}"
      disable_labels system "${THIRDPARTY_SYSTEM[@]}"
      ;;
  esac
}

# ---------------------------------------------------------------------------
# Wizard mode
# ---------------------------------------------------------------------------

wizard_mode() {
  local disable_flags=(0 0 0 0 0 0 0 0 0 0 0)
  local i key

  echo
  echo "M1-Air-Forever Wizard / 向导模式"
  echo "Answer each question. If you do not need a feature, it will be disabled."
  echo "不需要的功能会被禁用；需要就保留。"
  echo

  i=0; key="telemetry"
  if ! ask_yes_no "保留系统遥测、诊断和崩溃上报？ / Keep telemetry, diagnostics and crash reports?" n; then disable_flags[$i]=1; fi
  i=1; key="coreduet"
  if ! ask_yes_no "保留 CoreDuet 设备感知和预测？ / Keep CoreDuet device learning?" n; then disable_flags[$i]=1; fi
  i=2; key="siri"
  if ! ask_yes_no "保留 Siri 语音助手？ / Keep Siri assistant?" y; then disable_flags[$i]=1; fi
  i=3; key="widgets"
  if ! ask_yes_no "保留桌面小组件？ / Keep desktop widgets?" y; then disable_flags[$i]=1; fi
  i=4; key="spotlight"
  if ! ask_yes_no "保留 Spotlight 搜索和索引？ / Keep Spotlight search and indexing?" y; then disable_flags[$i]=1; fi
  i=5; key="sharing"
  if ! ask_yes_no "保留隔空投送、接力和屏幕共享？ / Keep AirDrop, Handoff and Screen Sharing?" y; then disable_flags[$i]=1; fi
  i=6; key="icloud"
  if ! ask_yes_no "保留 iCloud 同步？ / Keep iCloud sync?" y; then disable_flags[$i]=1; fi
  i=7; key="timemachine"
  if ! ask_yes_no "保留 Time Machine 备份？ / Keep Time Machine backups?" y; then disable_flags[$i]=1; fi
  i=8; key="quicklook"
  if ! ask_yes_no "保留 Quick Look 预览和缩略图？ / Keep Quick Look previews and thumbnails?" y; then disable_flags[$i]=1; fi
  i=9; key="findmy"
  if ! ask_yes_no "保留查找 Mac？ / Keep Find My?" y; then disable_flags[$i]=1; fi
  i=10; key="thirdparty"
  if ! ask_yes_no "保留第三方后台常驻？ / Keep third-party background jobs?" n; then disable_flags[$i]=1; fi

  echo
  echo "Summary / 摘要:"
  for i in "${!FEATURE_KEYS[@]}"; do
    if [ "${disable_flags[$i]}" -eq 1 ]; then
      printf '  disable: %s / %s\n' "${FEATURE_EN[$i]}" "${FEATURE_ZH[$i]}"
    fi
  done
  echo
  if ! ask_yes_no "Apply these changes now? / 现在执行这些更改？" y; then
    log "Wizard cancelled before apply"
    return
  fi
  if ask_yes_no "Dry-run only? / 只做 dry-run？" n; then DRY_RUN=1; fi

  for i in "${!FEATURE_KEYS[@]}"; do
    if [ "${disable_flags[$i]}" -eq 1 ]; then
      apply_feature "${FEATURE_KEYS[$i]}"
    fi
  done
  log "Wizard finished"
}

# ---------------------------------------------------------------------------
# Custom mode
# ---------------------------------------------------------------------------

custom_mode() {
  local disable_flags=(0 0 0 0 0 0 0 0 0 0 0)
  local input i

  while true; do
    clear
    echo "M1-Air-Forever Custom / 自定义模式"
    echo "Toggle feature groups, then apply. / 选择要禁用的功能组，然后执行。"
    echo
    for i in "${!FEATURE_KEYS[@]}"; do
      local mark="keep"
      [ "${disable_flags[$i]}" -eq 1 ] && mark="disable"
      printf '  %2d) [%-7s] %-42s %s\n' "$((i + 1))" "$mark" "${FEATURE_EN[$i]}" "${FEATURE_ZH[$i]}"
    done
    echo
    echo "Enter numbers separated by spaces to toggle, a=apply, d=dry-run, q=quit"
    echo "输入编号切换，a=执行，d=仅 dry-run，q=退出"
    read -r -p "> " input
    case "$input" in
      q|Q) log "Custom cancelled"; return ;;
      a|A) break ;;
      d|D) DRY_RUN=1; break ;;
      *)
        for n in $input; do
          if [[ "$n" =~ ^[0-9]+$ ]] && [ "$n" -ge 1 ] && [ "$n" -le "${#FEATURE_KEYS[@]}" ]; then
            i=$((n - 1))
            if [ "${disable_flags[$i]}" -eq 1 ]; then disable_flags[$i]=0; else disable_flags[$i]=1; fi
          fi
        done
        ;;
    esac
  done

  echo
  echo "Summary / 摘要:"
  for i in "${!FEATURE_KEYS[@]}"; do
    if [ "${disable_flags[$i]}" -eq 1 ]; then
      printf '  disable: %s / %s\n' "${FEATURE_EN[$i]}" "${FEATURE_ZH[$i]}"
    fi
  done
  if ! ask_yes_no "Apply these changes now? / 现在执行这些更改？" y; then
    log "Custom cancelled before apply"
    return
  fi
  if [ "$DRY_RUN" -eq 0 ] && ask_yes_no "Dry-run only? / 只做 dry-run？" n; then DRY_RUN=1; fi
  for i in "${!FEATURE_KEYS[@]}"; do
    if [ "${disable_flags[$i]}" -eq 1 ]; then
      apply_feature "${FEATURE_KEYS[$i]}"
    fi
  done
  log "Custom finished"
}

# ---------------------------------------------------------------------------
# Reports, wallpaper, rollback
# ---------------------------------------------------------------------------

ram_report() {
  echo
  echo "=== vm_stat ==="
  run_show vm_stat
  echo
  echo "=== memory_pressure ==="
  run_show memory_pressure
  echo
  echo "=== top memory processes ==="
  if [ "$DRY_RUN" -eq 1 ]; then
    echo "[dry-run] top -l 1 -o mem"
  else
    top -l 1 -o mem | head -25 | tee -a "$LOG_FILE"
  fi
}

wallpaper_menu() {
  echo
  echo "Wallpaper / 壁纸"
  echo "1) Set static image / 设置静态图片"
  echo "2) Restore previous wallpaper / 恢复之前的壁纸"
  echo "0) Back / 返回"
  read -r -p "> " choice
  case "$choice" in
    1)
      read -r -p "Image path / 图片路径: " image_path
      [ -n "$image_path" ] && run python3 "$SCRIPT_DIR/set-wallpaper.py" "$image_path"
      ;;
    2)
      run python3 "$SCRIPT_DIR/set-wallpaper.py" --restore
      ;;
  esac
}

chrome_menu() {
  echo
  echo "Chrome runners / Chrome 启动器"
  echo "  optimized: $SCRIPT_DIR/chrome/chrome-optimized-runner"
  echo "  low-gpu  : $SCRIPT_DIR/chrome/chrome-low-gpu-runner"
  echo "Quit Chrome completely before using a runner."
  echo "使用前请完全退出 Chrome。"
}

rollback_mode() {
  local kind a b
  echo
  echo "Rollback recorded changes / 回滚已记录更改"
  if [ ! -s "$STATE_FILE" ]; then
    echo "No state file entries: $STATE_FILE"
    return
  fi
  if ! ask_yes_no "Continue rollback? / 继续回滚？" y; then return; fi
  while IFS=$'\t' read -r kind a b; do
    case "$kind" in
      launchd)
        enable_one "$a" "$b"
        ;;
      action)
        case "$a" in
          spotlight_on) run $SUDO mdutil -a -i on ;;
          timemachine_on) run $SUDO tmutil enable ;;
          *) log "Unknown rollback action: $a" ;;
        esac
        ;;
      *) log "Unknown state line: $kind" ;;
    esac
  done <"$STATE_FILE"
  log "Rollback finished"
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

usage() {
  cat <<EOF
M1-Air-Forever optimizer

Usage:
  sudo ./m1-optimizer.sh [--wizard|--custom|--rollback] [--dry-run] [--debug]

Modes:
  --wizard      Step-by-step questions / 向导模式
  --custom      Toggle feature groups / 自定义模式
  --rollback    Restore recorded changes / 回滚
  --dry-run     Only log commands / 只记录不执行
  --debug       Bash debug output / 输出调试信息
EOF
}

main_menu() {
  while true; do
    clear
    echo "======================================"
    echo " M1-Air-Forever"
    echo " MacBook Air M1 2020 / 8GB"
    echo "======================================"
    echo "1) Wizard / 向导模式"
    echo "2) Custom / 自定义模式"
    echo "3) RAM & CPU report / 内存报告"
    echo "4) Wallpaper / 壁纸"
    echo "5) Chrome runners / Chrome 启动器"
    echo "6) Rollback / 回滚"
    echo "7) Show log path / 显示日志路径"
    echo "0) Exit / 退出"
    read -r -p "> " choice
    case "$choice" in
      1) wizard_mode ;;
      2) custom_mode ;;
      3) ram_report ;;
      4) wallpaper_menu ;;
      5) chrome_menu ;;
      6) rollback_mode ;;
      7) echo "Log: $LOG_FILE"; read -r -p "Press Enter..." _ ;;
      0) exit 0 ;;
    esac
    echo
    read -r -p "Press Enter to return to menu / 回车返回菜单..." _
  done
}

parse_args() {
  local mode=""
  while [ $# -gt 0 ]; do
    case "$1" in
      --wizard) mode="wizard" ;;
      --custom) mode="custom" ;;
      --rollback) mode="rollback" ;;
      --dry-run) DRY_RUN=1 ;;
      --debug) DEBUG=1 ;;
      --help|-h) usage; exit 0 ;;
      *) die "Unknown argument: $1" ;;
    esac
    shift
  done
  [ "$DEBUG" -eq 1 ] && set -x

  case "$mode" in
    wizard) wizard_mode ;;
    custom) custom_mode ;;
    rollback) rollback_mode ;;
    "") main_menu ;;
  esac
}

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
  usage
  exit 0
fi

if [ "$(id -u)" -ne 0 ]; then
  SUDO="sudo"
  TARGET_UID="$(id -u)"
  if ! sudo -v; then
    die "sudo is required for system services / 系统服务需要 sudo"
  fi
else
  SUDO=""
  if [ -n "${SUDO_USER:-}" ] && [ "${SUDO_USER}" != "root" ]; then
    TARGET_UID="$(id -u "${SUDO_USER}")"
  else
    TARGET_UID="$(stat -f %u /dev/console 2>/dev/null || echo 501)"
  fi
fi

log "Started ${APP_NAME}"
log "Target UID: ${TARGET_UID}"
parse_args "$@"
log "Log file: ${LOG_FILE}"
echo "Log: ${LOG_FILE}"
