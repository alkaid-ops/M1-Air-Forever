# MacBook Air M1 2020 8GB：20 年使用计划

> 目标：让 2020 款 MacBook Air M1 / 8GB 在 2026–2046 期间尽可能保持可用、低内存占用、低后台噪音、低 SSD 磨损。
>
> 这不是“把 8GB 当 64GB 用”的魔法仓库，而是一套长期维护路线：选对系统、裁掉不需要的后台、用轻量软件、控制 swap 和电池损耗。

## 先看结论

| 项目 | 建议 |
|---|---|
| 日常主力系统 | macOS 13 Ventura（8GB 体感最均衡） |
| 安全优先系统 | macOS 15 Sequoia + 本仓库裁剪方案 |
| 极限轻量/离线用途 | macOS 12 Monterey |
| 不建议长期日常 | macOS 11 Big Sur（EOL、现代软件兼容差） |
| 不建议 8GB 直接全功能使用 | macOS 14/15 默认后台全家桶、动态壁纸、Computer Use 长时间待机 |
| 最大 RAM 节省方向 | 静态壁纸、关闭 Spotlight/共享/iCloud/遥测、轻量浏览器、少用 Electron 常驻 |
| 长期硬件维护 | 3–5 年换一次电池；控制 swap；保持 10–20% 空闲磁盘；避免长期高温 |

## 作者相关项目

- Flameshot legacy builds：macOS 11+ / Apple Silicon arm64 的 Flameshot 重打包  
  <https://github.com/alkaid-ops/flameshot-legacy-builds>

这个项目专门解决“官方包最低要求 macOS 14/15，但 macOS 11/12/13 用户也需要截图工具”的问题。

## 20 年路线图

| 阶段 | 时间 | 定位 | 系统策略 | 重点 |
|---|---|---|---|---|
| 主力期 | 2026–2030 | 日常主力/开发/办公 | macOS 13/14/15，按需升级，重度裁剪 | 控制后台、RAM、swap、电池 |
| 副机期 | 2031–2035 | 第二台机器/离线办公 | 冻结在最后一个安全版本 | 换电池、清理服务、备份 |
| Linux/离线期 | 2036–2040 | 文档、媒体、远程终端 | Asahi Linux / 离线 macOS | 零件维护、离线数据 |
| 归档期 | 2041–2046 | 复古/离线/数据归档 | 离线系统镜像 | 数据可读、硬件可修 |

现实说明：Apple 不会给一台 M1 提供 20 年官方支持。这个计划的“20 年”指持续可用，而不是一直拿到官方系统更新。

## macOS 版本矩阵

| 版本 | 8GB 体感 | 安全更新 | 现代软件兼容 | 建议 |
|---|---|---|---|---|
| macOS 11 Big Sur | 最轻 | 已结束 | 差 | 只适合冻结/离线用途 |
| macOS 12 Monterey | 很轻 | 已结束 | 一般 | 8GB 性能最优，适合离线/副机 |
| macOS 13 Ventura | 轻 | 已结束/接近结束 | 较好 | **日常平衡首选** |
| macOS 14 Sonoma | 偏重 | 较长 | 好 | 需要新功能时用，必须裁剪 |
| macOS 15 Sequoia | 最重 | 最长 | 最好 | 安全优先，配合裁剪 |

详细分析见 [docs/macos-versions.md](docs/macos-versions.md)。

## 系统裁剪

本仓库提供以下脚本，全部默认 dry-run，先看再执行：

| 脚本 | 作用 | 风险 |
|---|---|---|
| `scripts/disable-apple-extra.sh` | 关闭 Time Machine、Quick Look、Find My、iCloud/更新下载 | 备份、预览、查找会失效 |
| `scripts/disable-apple-residual.sh` | 关闭 CoreDuet、遥测、广告、Widget timeline 等 | 不影响 Siri/听写；保留壁纸 |
| `scripts/disable-spotlight-sharing.sh` | 关闭 Spotlight、AirDrop/Handoff/屏幕共享 | 搜索、隔空投送会失效 |
| `scripts/disable-extra-launchd.sh` | 关闭第三方常驻后台 | 需要逐项确认 |
| `scripts/set-wallpaper.py` | 切换静态壁纸/备份/恢复 | 只改壁纸存储 |

使用前请阅读 [docs/debloat.md](docs/debloat.md)。不要在 Screen Sharing 连接里执行 `--stop`。

## RAM 优化

8GB M1 的关键不是“清空内存”，而是减少后台持续占用和 swap：

- 不要关闭 macOS 内存压缩；8GB 机器关掉压缩会显著增加 swap 和 SSD 写入。
- 优先关闭不用的 iCloud、Spotlight、共享、遥测、Widget、动态壁纸。
- 浏览器是最大变量：少开常驻标签页，Chrome 可用 `scripts/chrome/` 里的启动器限制 GPU/语音识别。
- 软件优先选原生/轻量应用，减少 Electron 常驻。
- 静态壁纸实测约 84MB settled；动态 Sonoma 壁纸 active 约 147MB。
- Computer Use / ReplayKit 有已知 `replayd` 高 CPU 问题，见 [docs/codex-known-issues.md](docs/codex-known-issues.md)。

详细方法见 [docs/ram-optimization.md](docs/ram-optimization.md)。

## 软件推荐

优先保留：

- Rectangle：窗口管理
- Shottr：截图
- Flameshot legacy builds：macOS 11+ 截图方案
- LocalSend：局域网传输
- KeepingYouAwake：保持唤醒
- Clash Verge：网络代理
- Sogou 输入法：中文输入

更多分类和替代方案见 [docs/software.md](docs/software.md)。

## 仓库结构

```text
.
├── README.md
├── docs/
│   ├── 20-year-plan.md
│   ├── codex-known-issues.md
│   ├── debloat.md
│   ├── macos-versions.md
│   ├── ram-optimization.md
│   └── software.md
└── scripts/
    ├── disable-apple-extra.sh
    ├── disable-apple-residual.sh
    ├── disable-extra-launchd.sh
    ├── disable-spotlight-sharing.sh
    ├── set-wallpaper.py
    └── chrome/
        ├── ChromeLowGPU-Info.plist
        ├── ChromeOptimized-Info.plist
        ├── chrome-low-gpu-runner
        └── chrome-optimized-runner
```

## 安全与回滚

- 所有 launchd 脚本都保留 `--enable`，可恢复对应服务。
- 修改系统服务通常需要关闭 SIP 后才持久；关闭 SIP 会降低系统安全性。
- 不要删除 `/System` 里的系统组件；只禁用不需要的后台服务。
- 执行前先备份，先 dry-run，先单项验证。

## License

MIT。脚本按原样提供，不提供任何担保；使用前请确认你理解每一条改动。
