# macOS 系统裁剪

核心原则：**不删除只读系统快照里的组件，只禁用不需要的 launchd 服务**。这样可以保留系统签名、更新和回滚能力。

## 开始前

- 先备份。
- 先 dry-run：
  ```bash
  sudo ./scripts/m1-optimizer.sh --dry-run --wizard
  ```
- 一次只处理一个功能组，重启后观察 24 小时。
- 不要在 Screen Sharing 连接里执行 stop 操作。

## 交互脚本

唯一入口：

```bash
sudo ./scripts/m1-optimizer.sh
```

模式：

- **向导模式**：一项一项问你要不要保留。
- **自定义模式**：勾选要禁用的功能组。
- **回滚**：恢复脚本记录过的 launchd 更改。

日志：

```text
~/Library/Logs/M1-Air-Forever/optimizer-YYYYmmdd-HHMMSS.log
```

## 功能组

| 功能组 | 会关闭 | 代价 |
|---|---|---|
| 遥测 | 诊断、崩溃上报、广告 | 不再上传诊断 |
| CoreDuet | 设备感知、预测 | 跨设备上下文减弱 |
| Siri | `com.apple.Siri.agent` | Siri 关闭；听写保留 |
| Widget | `chronod` | 桌面小组件停止 |
| Spotlight | 索引和 mdworker | 搜索失效 |
| 共享 | AirDrop、接力、屏幕共享、SMB/SSH | 共享失效 |
| iCloud | 云同步、照片分析 | iCloud 同步失效 |
| Time Machine | 本地备份 | 不再自动备份 |
| Quick Look | 预览和缩略图 | Finder 预览失效 |
| Find My | 查找 Mac | 查找失效 |
| 第三方后台 | OneDrive、ToDesk、更新器等 | 对应后台停止 |

## 回滚

```bash
sudo ./scripts/m1-optimizer.sh --rollback
```

状态文件：

```text
~/Library/Application Support/M1-Air-Forever/state.tsv
```

`scripts/legacy/` 里保留了旧的拆分脚本，只作为参考；当前入口是 `m1-optimizer.sh`。

## 壁纸和 Computer Use

- 保留 `com.apple.wallpaper.agent`。
- 动态锁屏需要 `com.apple.wallpaper.extension.video`。
- Computer Use / ReplayKit 可能让 `replayd` 高 CPU，见 [known-issues.md](known-issues.md)。

## 不要禁用

- WindowServer
- Finder
- cfprefsd
- mDNSResponder
- configd
- kernel_task
