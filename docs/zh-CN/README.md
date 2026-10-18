<div align="center">

<h1>M1-Air-Forever</h1>

**MacBook Air M1 2020 / 8GB 的 20 年使用计划**

[![License: MIT](https://img.shields.io/badge/license-MIT-brightgreen.svg?style=flat-square)](../../LICENSE)

[English](../../README.md) | **简体中文**

</div>

## 这是什么

M1-Air-Forever 是一套面向 MacBook Air M1 2020 / 8GB 的长期维护与优化指南，目标是让这台机器尽可能长时间地保持可用。

它关注：

- macOS 11–15 的版本选择；
- 不删除系统组件的前提下裁剪后台服务；
- 降低 RAM 压力与 swap 磨损；
- 选择轻量软件；
- 电池、SSD 与数据的 20 年维护路线。

这不是“把 8GB 变成 64GB”的魔法，而是减少后台、选择轻量软件、控制 swap、选对系统版本。

## 快速结论

| 项目 | 建议 |
|---|---|
| 日常平衡 | macOS 13 Ventura |
| 安全优先 | macOS 15 Sequoia + 裁剪 |
| 离线/极限轻量 | macOS 12 Monterey |
| 不建议日常 | macOS 11 Big Sur |
| RAM 节省 | 静态壁纸、关闭 Spotlight/共享/iCloud/遥测、轻量浏览器 |
| 长期健康 | 3–5 年换电池、控制 swap、保持 10–20% 空闲磁盘 |

## 作者项目

- Flameshot legacy builds：macOS 11+ / Apple Silicon arm64 的 Flameshot 重打包  
  <https://github.com/alkaid-ops/flameshot-legacy-builds>

## 交互脚本

主入口只有一个：

```bash
git clone https://github.com/alkaid-ops/M1-Air-Forever.git
cd M1-Air-Forever
sudo ./scripts/m1-optimizer.sh
```

模式：

```bash
sudo ./scripts/m1-optimizer.sh --wizard     # 向导模式
sudo ./scripts/m1-optimizer.sh --custom     # 自定义勾选
sudo ./scripts/m1-optimizer.sh --rollback   # 回滚
sudo ./scripts/m1-optimizer.sh --dry-run    # 只记录不执行
```

日志路径：

```text
~/Library/Logs/M1-Air-Forever/optimizer-YYYYmmdd-HHMMSS.log
```

### 向导模式

向导会一项一项问：

```text
保留 Spotlight 搜索和索引？ [Y/n]
保留隔空投送、接力和屏幕共享？ [Y/n]
保留 Time Machine 备份？ [Y/n]
```

回答 `n` 就禁用对应功能组。

### 自定义模式

自定义模式显示勾选列表：

```text
1) [disable] 遥测、诊断和广告
2) [keep]    CoreDuet 设备感知
3) [keep]    Siri 语音助手
...
```

输入编号切换，`a` 执行，`d` 只 dry-run，`q` 退出。

## macOS 版本矩阵

| 版本 | 8GB 体感 | 安全更新 | 现代软件 | 建议 |
|---|---|---|---|---|
| macOS 11 Big Sur | 很轻 | 已结束 | 差 | 只适合离线/归档 |
| macOS 12 Monterey | 很轻 | 已结束 | 一般 | 离线/副机 |
| macOS 13 Ventura | 轻 | 接近结束 | 较好 | **日常平衡首选** |
| macOS 14 Sonoma | 偏重 | 较长 | 好 | 需要裁剪 |
| macOS 15 Sequoia | 最重 | 最长 | 最好 | 安全优先 + 裁剪 |

详细说明：[macOS 版本](macos-versions.md)

## RAM 优化

本类机器实测：

| 壁纸 | RSS |
|---|---:|
| 动态桌面 + 锁屏 | 约 147MB active |
| 静态 Sonoma 图 | 约 84MB settled |
| 静态纯色 | 通常更低 |

原则：

- 8GB 不要禁用内存压缩。
- 优先裁剪 Spotlight、共享、iCloud、遥测、Widget。
- 浏览器是最大变量。
- 动态壁纸只在插电/演示时用。
- Computer Use / ReplayKit 有 `replayd` 高 CPU 问题，见 [known issues](known-issues.md)。

详细说明：[RAM 优化](ram-optimization.md)

## 软件推荐

| 工具 | 用途 | 链接 |
|---|---|---|
| Rectangle | 窗口管理 | <https://rectangleapp.com/> |
| Shottr | 截图/标注 | <https://shottr.cc/> |
| Flameshot legacy builds | macOS 11+ 截图 | <https://github.com/alkaid-ops/flameshot-legacy-builds> |
| LocalSend | 局域网传输 | <https://localsend.org/> |
| KeepingYouAwake | 防休眠 | <https://keepingyouawake.app/> |
| Clash Verge | 网络代理 | <https://github.com/clash-verge-rev/clash-verge-rev> |
| Sogou 输入法 | 中文输入 | 官网 |

详细说明：[软件推荐](software.md)

## 20 年路线

| 阶段 | 系统 | 用途 |
|---|---|---|
| 2026–2030 | macOS 13/14/15 | 主力 |
| 2031–2035 | 最后安全版本 | 副机/离线 |
| 2036–2040 | Asahi Linux / 离线 macOS | 文档、媒体、终端 |
| 2041–2046 | 离线系统镜像 | 归档/复古 |

详细说明：[20 年计划](20-year-plan.md)

## 仓库结构

```text
.
├── README.md
├── CONTRIBUTING.md
├── LICENSE
├── .github/
├── docs/
│   ├── images/
│   ├── en/
│   └── zh-CN/
└── scripts/
    ├── m1-optimizer.sh
    ├── set-wallpaper.py
    ├── chrome/
    └── legacy/
```

## 安全

- 执行前先读脚本。
- 系统服务需要 `sudo`。
- 脚本会记录更改，可回滚。
- 禁用系统服务可能破坏你依赖的功能。
- 不要删除 `/System` 组件。

## 贡献

欢迎提交 issue 和 PR。见 [CONTRIBUTING.md](../../CONTRIBUTING.md)。

## License

MIT
