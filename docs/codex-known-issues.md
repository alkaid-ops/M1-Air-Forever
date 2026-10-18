# Codex / Computer Use 已知问题

## replayd 高 CPU

相关 issue：

- [#37420](https://github.com/openai/codex/issues/37420)：Computer Use 导致 `replayd` XPC reconnect loop，空闲约 90% CPU
- [#30503](https://github.com/openai/codex/issues/30503)：Computer Use helper 空闲时拉起 ReplayKit
- [#35659](https://github.com/openai/codex/issues/35659)：ScreenCaptureKit 流未释放
- [#51035](https://github.com/openai/codex/issues/51035)：Appshots 截图超时

现象：

- `/usr/libexec/replayd` 长时间 70%–90% CPU
- `SkyComputerUseService` 同时占用 15%–20%
- 机器发热、卡顿、耗电
- 杀 `replayd` 无效，会被重新拉起

临时处理：

```bash
pkill -x SkyComputerUseService
```

更彻底但会关闭 Computer Use：

```bash
tccutil reset ScreenCapture com.openai.sky.CUAService
```

退出并重启 ChatGPT/Codex 也能清理。

## Computer Use 选项缺失

相关 issue：

- [#52191](https://github.com/openai/codex/issues/52191)：macOS 插件缺失，managed service 启动失败
- [#43801](https://github.com/openai/codex/issues/43801)：没有 Computer Use 安装项 / Any App
- [#45696](https://github.com/openai/codex/issues/45696)：Computer Use / `@Computer` 不可用
- [#45671](https://github.com/openai/codex/issues/45671)：插件已启用但工具不可用

用户侧 workaround：

1. 确认 `marketplaces.openai-bundled.source` 与当前 `CODEX_HOME/.tmp/bundled-marketplaces/openai-bundled` 路径一致。
2. 删除自动写入的禁用回退：
   ```toml
   [mcp_servers.cua_repl]
   command = "/Applications/ChatGPT.app/Contents/MacOS/ChatGPT"
   enabled = false
   ```
3. 重新安装插件：
   ```bash
   codex plugin remove computer-use@openai-bundled
   codex plugin remove unified-computer-use@openai-bundled
   codex plugin add computer-use@openai-bundled
   codex plugin add unified-computer-use@openai-bundled
   ```
4. 完全退出并重开 ChatGPT/Codex。
5. 检查：
   ```bash
   codex mcp list | grep cua_repl
   ```
   应为 enabled。

## 壁纸内存

本机实测：

| 方案 | RSS |
|---|---:|
| 动态桌面 + 锁屏 Sonoma | 约 147MB active |
| 静态 Sonoma 图 | 约 84MB settled |
| 静态纯色 | 通常更低 |

注意：

- `WallpaperAgent` 不能禁用，否则桌面/锁屏黑。
- 动态锁屏依赖 `WallpaperVideoExtension`。
- 持久静态锁屏要用系统设置，不要只改 plist。
