# RAM 优化：8GB M1 的长期策略

8GB 统一内存的关键不是“清空”，而是减少持续占用、减少 swap、避免 SSD 写入放大。

## 先测量

```bash
# 内存压力
memory_pressure

# 分页/压缩
vm_stat

# 进程内存排行
top -o mem

# 指定进程 RSS
ps -axo pid,rss,%cpu,comm | sort -k2 -nr | head -20
```

关注：

- `Pages occupied by compressor` 是否持续很高
- `Pageouts` 是否持续增长
- `memory_pressure` 的 free percentage
- swap 是否长期存在

## 8GB 规则

1. 不要禁用内存压缩。
2. 不要让浏览器长期占用 2GB+。
3. 不要让 Electron 应用常驻超过 2–3 个。
4. 不要长期开动态壁纸 + Computer Use + 多个浏览器。
5. 保持 10–20% 空闲磁盘，避免 APFS 压力。
6. 电池模式开低电量模式。

## 后台服务

优先裁剪：

- Spotlight / mdworker
- iCloud / cloudd / bird
- Time Machine backupd
- CoreDuet / 遥测 / 广告
- Widget timeline
- 第三方更新器 / 网盘同步

参考 [debloat.md](debloat.md)。

## 浏览器

Chrome 是最大变量。建议：

- 日常不超过 10–20 个活动标签。
- 用 `scripts/chrome/chrome-optimized-runner` 限制 GPU 预算和语音识别。
- 极低内存场景用 `chrome-low-gpu-runner`（禁用 GPU，CPU 会上升）。
- 每月清理扩展；每个扩展都是常驻内存。
- 可用 Safari/Orion 作为第二浏览器，但不要同时开几百个标签。

## 壁纸

实测：

| 方案 | 壁纸相关 RSS |
|---|---:|
| 完全动态 Sonoma | 约 147MB active |
| 静态 Sonoma 图 | 约 84MB settled |
| 静态纯色 | 通常更低 |

建议长期使用静态图或纯色。动态壁纸只在插电、短时间演示时使用。

## Computer Use / ReplayKit

已知问题：

- `SkyComputerUseService` 空闲时可能让 `/usr/libexec/replayd` 持续 70%–90% CPU。
- 临时处理：
  ```bash
  pkill -x SkyComputerUseService
  ```
- 更彻底但会关闭 Computer Use：
  ```bash
  tccutil reset ScreenCapture com.openai.sky.CUAService
  ```

详见 [codex-known-issues.md](codex-known-issues.md)。

## WindowServer

`WindowServer` 是 macOS 的显示合成进程，不是垃圾进程。

- 外接高刷显示器会提高占用。
- 动态壁纸、透明效果、大量窗口动画会提高占用。
- 不要 kill `WindowServer`；那会注销当前图形会话。

## SSD 和 swap

- swap 本身正常；频繁大量 swap 才是问题。
- 8GB 机器不要跑长期本地大模型、4K 多轨剪辑、多个虚拟机。
- 减少内存压缩会加剧 swap，不要做。
- 监控 `Pageouts` 和磁盘写入。

## 年度维护

- 清点登录项和 LaunchAgents。
- 检查电池健康。
- 检查 swap / 内存压力。
- 清理浏览器扩展。
- 重新评估系统版本。
- 做完整备份。
