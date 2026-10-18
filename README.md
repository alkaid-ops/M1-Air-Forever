# M1-Air-Forever

## 免责声明

本项目提供的脚本、配置和文档仅供参考，使用风险由使用者自行承担。

- 禁用系统服务、修改 launchd、壁纸、Chrome 启动参数或切换 Linux，可能导致系统功能异常、数据丢失、无法启动、失去安全更新或失去 Apple 支持。
- 关闭 SIP、Gatekeeper、FileVault 会降低系统安全性。
- 本项目与 Apple、OpenAI、Flameshot 等项目没有官方关联。
- 作者不对任何直接或间接损失负责。
- 请先备份数据，并优先在虚拟机或非主力机器上验证；保留可回滚方案。


---
## MacBook Air M1 2020 / 8GB 的 20 年使用计划。

**简体中文** | [English](docs/en/README.md)

目标不是“跑最新大软件”，而是在满足日常使用的前提下，让这台机器在 macOS 11–15 范围内长期保持低后台、低 RAM、低 swap、低卡顿，并选择性运行大软件。



---

## 核心原则

- 只用 macOS 11–15 或 Linux。8GB M1 运行新版 macOS 可能只剩约 2GB 可用 RAM，容易内存压力、swap、卡顿。
- 禁用不需要的系统服务，不删除系统组件。
- 软件选型目标：
  - 后台 RAM ≤100MB，前台应用 RAM ≤300MB
  - 优先 Rust / C++ / C，第二梯队 Go / Zig / Swift
  - 避免 WebView / Electron，除非没有替代
  - 软件尽量跨平台，macOS 和 Linux 保持一致
- 电池只在健康度低或续航不满足需求时更换，不按固定年限换。

---

## macOS 11–15 版本选择

| 版本 | 8GB 体感 | 安全更新 | 现代软件 | 建议 |
|---|---|---|---|---|
| macOS 11 Big Sur | 很轻 | 已结束 | 差 | 升级到 macOS 12 |
| macOS 12 Monterey | 很轻 | 已结束 | 一般 | 最大性能 |
| macOS 13 Ventura | 轻 | 接近结束 | 较好 | **日常平衡首选** |
| macOS 14 Sonoma | 偏重 | 较长 | 好 | 裁剪后台 |
| macOS 15 Sequoia | 最重 | 最长 | 最好 | 裁剪后台 |

推荐：

- 日常主力：macOS 13 Ventura
- 极限轻量：macOS 12 Monterey
- 当前实测环境：macOS 14 Sonoma
- 不建议：macOS 11 作为长期主力

> PS：我懒得降级；当前使用 macOS 14，本仓库基于 macOS 14 实测。

---

## 20 年路线

| 阶段 | 系统 | 用途 | 重点 |
|---|---|---|---|
| 2026–2030 | macOS 13/14/15 | 主力 | 低 RAM、低 swap、低后台 |
| 2031–2035 | 最后安全版本 | 副机/离线 | 冻结系统、继续维护 |
| 2036–2040 | Asahi Linux / 离线 macOS | 文档、媒体、终端 | 硬件兼容验证 |
| 2041–2046 | 离线系统镜像 | 归档/复古 | 数据可读、硬件可修 |

电池：

- 只在健康度明显下降或续航不满足需求时更换。
- 长期插电可限制充电到 70–80%。
- 避免长期高温 + 满电。

---

## 低 RAM 软件目标

目标：

- 后台 RAM ≤100MB
- 前台应用 RAM ≤300MB
- 尽量不用 WebView / Electron
- 尽量用原生 GUI 或 TUI/CLI

语言优先级：

| 梯队 | 语言 | 说明 |
|---|---|---|
| 第一梯队 | Rust、C++、C | 原生内存布局、二进制小、运行时可控 |
| 第二梯队 | Go、Zig、Swift | 性能好；Go 有 GC，Zig/Swift 更原生 |
| 第三梯队 | Python、Lua、shell | 适合工具，不适合长期常驻 GUI |
| 默认避免 | Electron、WebView 重应用、JVM GUI | 基线内存大 |

AI 辅助编译方向：

- release 构建、LTO、strip、禁用不用的特性。
- 减少动态 WebView/Electron 运行时。
- 优先系统库，避免重复打包。
- Linux 上优先发行版包，必要时再自行编译。

---

## 系统裁剪：交互脚本

唯一入口：

```bash
sudo ./scripts/m1-optimizer.sh
```

模式：

```bash
sudo ./scripts/m1-optimizer.sh --wizard     # 向导：一项一项问
sudo ./scripts/m1-optimizer.sh --custom     # 自定义：勾选功能组
sudo ./scripts/m1-optimizer.sh --rollback   # 回滚
sudo ./scripts/m1-optimizer.sh --dry-run    # 只记录，不执行
```

日志：

```text
~/Library/Logs/M1-Air-Forever/optimizer-YYYYmmdd-HHMMSS.log
```

功能组：

| 功能组 | 关闭内容 | 代价 |
|---|---|---|
| 遥测/广告 | 诊断、崩溃上报、广告 | 无诊断上传 |
| CoreDuet | 设备感知、预测 | 跨设备上下文减弱 |
| Siri | Siri agent | Siri 关闭，听写保留 |
| Widget | chronod | 桌面小组件停止 |
| Spotlight | 索引、mdworker | 搜索失效 |
| 共享 | AirDrop、接力、屏幕共享、SMB/SSH | 共享失效 |
| iCloud | 云同步、照片分析 | iCloud 同步失效 |
| Time Machine | 备份 | 不再自动备份 |
| Quick Look | 预览、缩略图 | Finder 预览失效 |
| Find My | 查找 Mac | 查找失效 |
| 第三方后台 | OneDrive、ToDesk、更新器等 | 对应后台停止 |

脚本会记录状态并支持回滚：

```text
~/Library/Application Support/M1-Air-Forever/state.tsv
```

不要禁用：

- WindowServer
- Finder
- cfprefsd
- mDNSResponder
- configd
- kernel_task
- `com.apple.wallpaper.agent`（会黑屏）

---

## RAM 优化

测量：

```bash
memory_pressure
vm_stat
top -o mem
ps -axo pid,rss,%cpu,comm | sort -k2 -nr | head -20
```

优先处理：

- Spotlight / mdworker
- iCloud / cloudd / bird
- Time Machine
- 遥测、广告、CoreDuet
- Widget timeline
- 第三方更新器和网盘同步

8GB 规则：

- 不要禁用内存压缩。
- 不要同时常驻多个浏览器。
- 浏览器标签控制在 10–20 个。
- 动态壁纸只在插电/演示时用。
- 静态 Sonoma 壁纸约 84MB settled；动态桌面+锁屏约 147MB active。
- 保持 10–20% 空闲磁盘。

---

## 软件推荐

必留：

- Rectangle：窗口管理
- Shottr：截图
- Flameshot legacy builds：macOS 11+ 截图，作者维护  
  <https://github.com/alkaid-ops/flameshot-legacy-builds>
- LocalSend：局域网传输
- KeepingYouAwake：防休眠
- Clash Verge / Mihomo：网络代理
- Sogou 输入法；Linux 用 Fcitx5 + Rime

跨平台优先：

| 类别 | macOS | Linux | 语言/运行时 |
|---|---|---|---|
| 终端 | WezTerm / Alacritty / Ghostty | WezTerm / Alacritty / Ghostty | Rust / Zig |
| 编辑器 | Helix / Neovim / Zed | Helix / Neovim / Zed | Rust / C / Rust |
| 浏览器 | Firefox / Safari / Orion | Firefox / Chromium | Rust / C++ |
| 媒体 | IINA / mpv | mpv / VLC | C / C++ |
| 截图 | Shottr / Flameshot | Flameshot | C++/Qt |
| 文件管理 | Finder / Yazi | Nautilus / Dolphin / Yazi | 原生 / Rust |
| 笔记 | Apple Notes / Markdown + Neovim | Markdown + Neovim / Zettlr | C/Rust |
| 同步 | Syncthing / LocalSend | Syncthing / LocalSend | Go / Flutter |
| 输入法 | Squirrel/Rime | Fcitx5 + Rime | C++ |
| PDF | Skim / Sioyek / Zathura | Sioyek / Zathura / Okular | C/C++ |
| 代理 | Mihomo + Clash Verge | Mihomo + Clash Verge | Go / Tauri |

避免长期常驻：

- 多个网盘同步
- Adobe Creative Cloud 后台
- 多个浏览器同时常驻
- 游戏平台后台
- 自动更新器
- 桌面 Widget 全家桶

---

## Linux 方案

推荐发行版：

| 发行版 | 包体系 | 原因 | 注意 |
|---|---|---|---|
| Fedora Asahi Remix | RPM | Asahi 官方发行版 | 硬件支持最好 |
| Debian Asahi | DEB | 稳定、小 | 支持可能滞后 |
| Ubuntu Asahi | DEB | 桌面熟悉 | 需确认当前 M1 Air 支持 |

不要选 Arch / Manjaro 等滚动发行版。

切换前确认：

- Wi-Fi / 蓝牙
- 麦克风
- 扬声器 DSP
- GPU 加速
- 摄像头
- 睡眠/唤醒
- Touch ID
- Thunderbolt/USB-C
- 外接显示器

Linux 平替：

| macOS | Linux |
|---|---|
| Safari | Firefox |
| Shottr | Flameshot |
| IINA | mpv |
| Rectangle | Sway/Hyprland 平铺 |
| KeepingYouAwake | systemd-inhibit |
| Squirrel/Rime | Fcitx5 + Rime |
| Skim | Zathura / Sioyek |
| Apple Notes | Markdown + Neovim |

---

## 已知问题

Computer Use / ReplayKit：

- `replayd` 空闲时可能 70–90% CPU。
- 相关 issue：  
  <https://github.com/openai/codex/issues/37420>

临时处理：

```bash
pkill -x SkyComputerUseService
```

更彻底但会关闭 Computer Use：

```bash
tccutil reset ScreenCapture com.openai.sky.CUAService
```

---

## 仓库结构

```text
.
├── README.md
├── LICENSE
├── docs/
│   └── en/
│       └── README.md
└── scripts/
    ├── m1-optimizer.sh
    ├── set-wallpaper.py
    └── chrome/
        ├── ChromeOptimized-Info.plist
        └── chrome-optimized-runner
```

---

## License

MIT

---