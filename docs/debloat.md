# macOS 系统裁剪

核心原则：**不删除只读系统快照里的组件，只禁用不需要的 launchd 服务**。这样可以保留系统签名、更新和回滚能力。

## 裁剪前

- 先备份。
- 先运行 dry-run：
  ```bash
  ./scripts/disable-apple-residual.sh --dry-run
  ```
- 一次只启用一个分组，重启，观察 24 小时。
- 不要在 Screen Sharing 连接里执行 `--stop`。

## 脚本说明

### disable-apple-extra.sh

关闭：

- Time Machine
- Quick Look / Finder 缩略图
- Find My
- iCloud / App Store 后台下载 / 软件更新

代价：备份、预览、查找、iCloud 同步、后台更新失效。

### disable-apple-residual.sh

关闭：

- CoreDuet / 设备感知 / 预测
- 诊断、遥测、崩溃上报
- 广告/推荐
- Widget timeline（chronod）

保留：

- `WallpaperAgent`
- Siri / 听写

注意：壁纸相关进程不能乱杀，否则桌面和锁屏会黑。

### disable-spotlight-sharing.sh

关闭：

- Spotlight / CoreSpotlight / mdworker
- AirDrop / Handoff / Rapport
- 屏幕共享 / SMB / SSH

代价：Spotlight 搜索、隔空投送、接力、屏幕共享、文件共享失效。

### disable-extra-launchd.sh

关闭第三方常驻：

- ToDesk / Sunlogin / RustDesk
- OneDrive / Microsoft AutoUpdate
- Google Keystone
- Karabiner / BetterDisplay / 百度网盘等

执行前逐项确认，不要把你要用的软件一起关掉。

## 推荐顺序

```bash
# 1. 只关遥测/广告/Widget
./scripts/disable-apple-residual.sh --apply
reboot

# 2. 关 Spotlight/共享
./scripts/disable-spotlight-sharing.sh --apply
reboot

# 3. 关 iCloud/Time Machine/Quick Look/Find My
./scripts/disable-apple-extra.sh --apply
reboot

# 4. 最后处理第三方后台
./scripts/disable-extra-launchd.sh --apply
```

## 回滚

每个脚本都支持：

```bash
./scripts/disable-apple-residual.sh --enable
./scripts/disable-spotlight-sharing.sh --enable
./scripts/disable-apple-extra.sh --enable
./scripts/disable-extra-launchd.sh --enable
```

最彻底的回滚：

```bash
sudo rm -f /private/var/db/com.apple.xpc.launchd/disabled*.plist
reboot
```

这会恢复所有 launchd 禁用状态，包括你没想恢复的项目；执行前先确认。

## 壁纸和 Computer Use 注意事项

- 不要禁用 `com.apple.wallpaper.agent`。
- 动态锁屏需要 `com.apple.wallpaper.extension.video`；禁用后锁屏可能黑。
- Computer Use / ReplayKit 有已知 `replayd` 高 CPU 问题；见 [codex-known-issues.md](codex-known-issues.md)。

## 手动清理

检查：

```bash
ls ~/Library/LaunchAgents
ls /Library/LaunchAgents
ls /Library/LaunchDaemons
```

重点关注：

- OneDrive
- Adobe Creative Cloud
- Google Keystone
- 网盘同步
- 自动更新器
- 游戏平台后台

## 不要做的事

- 不要删除 `/System` 里的系统 App 来“省内存”；多数 App 不常驻，删了也不省 RAM。
- 不要禁用 WindowServer、Finder、cfprefsd、mDNSResponder、configd、kernel_task。
- 不要修改 `vm_compression_limit`；8GB 机器会更容易 swap。
