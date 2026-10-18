# 软件推荐：8GB M1 的轻量组合

目标：少常驻、少 Electron、少后台同步、保留真正提高效率的工具。

## 原则

- 优先原生 App，其次 Tauri/Swift/Qt，最后 Electron。
- 同类工具只保留一个常驻。
- 自动更新器尽量改成手动更新。
- 云盘同步只在需要时启动。
- 浏览器扩展越少越好。

## 必留工具

| 工具 | 用途 | 链接 |
|---|---|---|
| Rectangle | 窗口管理 | <https://rectangleapp.com/> |
| Shottr | 截图/标注 | <https://shottr.cc/> |
| Flameshot legacy builds | macOS 11+ 截图，作者维护 | <https://github.com/alkaid-ops/flameshot-legacy-builds> |
| LocalSend | 局域网文件传输 | <https://localsend.org/> |
| KeepingYouAwake | 防休眠 | <https://keepingyouawake.app/> |
| Clash Verge | 网络代理 | <https://github.com/clash-verge-rev/clash-verge-rev> |
| Sogou 输入法 | 中文输入 | 官网下载 |

## 浏览器

| 选择 | 适合 | 注意 |
|---|---|---|
| Safari | 最省电、系统集成 | 扩展少，网页兼容偶尔差 |
| Orion | WebKit + Chrome 扩展 | 适合不喜欢 Safari UI 的人 |
| Chrome + 本仓库启动器 | 兼容最好 | RAM 最高，必须限制标签和扩展 |
| Firefox | 平衡 | 也吃内存，但比 Chrome 稍可控 |

建议：Chrome 或 Safari 二选一常驻，另一个只在需要时开。

## 系统工具

| 工具 | 用途 | 备注 |
|---|---|---|
| Stats | 菜单栏监控 CPU/RAM/网络 | 原生、轻量 |
| Ice / Hidden Bar | 菜单栏收纳 | 二选一 |
| AppCleaner | 卸载残留 | 手动运行 |
| MonitorControl | 外接显示器亮度/音量 | 外接屏才需要 |
| AlDente | 充电限制 | 长期插电时有用 |
| Itsycal | 菜单栏日历 | 轻量 |

## 媒体

| 工具 | 用途 |
|---|---|
| IINA | 原生 mpv 播放器 |
| VLC | 兼容性兜底 |
| mpv | 极客/脚本播放 |
| HandBrake | 转码，按需运行 |

避免长期开视频转码；M1 无风扇，长时间满载会降频。

## 开发

| 工具 | 说明 |
|---|---|
| VS Code | 功能强，但 Electron 吃内存；控制扩展 |
| Zed | 更轻的现代编辑器 |
| Sublime Text | 极轻，老牌 |
| Neovim | 最轻，适合终端党 |
| Xcode | 只在大项目时开；8GB 会紧张 |
| Docker | 尽量别常驻；用远程或按需启动 |
| iTerm2 / WezTerm | 终端，按需选择 |

## 办公与笔记

| 工具 | 说明 |
|---|---|
| Apple Notes | 原生、轻量 |
| Obsidian | 功能强，但 Electron；只开一个 vault |
| Typora | Markdown，较轻 |
| LibreOffice | 兼容 Office，启动慢 |
| Microsoft Office | 兼容最好，但后台多 |

## 安全

| 工具 | 用途 |
|---|---|
| LuLu | 出站防火墙 |
| KnockKnock | 检查常驻项 |
| Malwarebytes | 按需扫描 |

不要同时装多个杀毒/防火墙常驻。

## 避免长期常驻

- 多个网盘同步客户端
- Adobe Creative Cloud 后台
- 多个浏览器同时常驻
- 多个输入法/剪贴板管理器
- 游戏平台后台
- 自动更新器
- 桌面 Widget 全家桶

## 安装后检查

```bash
ls ~/Library/LaunchAgents
ls /Library/LaunchAgents
ls /Library/LaunchDaemons
```

只保留你真正需要的常驻项。
