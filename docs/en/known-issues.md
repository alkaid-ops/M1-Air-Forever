# Known Issues

## replayd high CPU

Issues:

- [#37420](https://github.com/openai/codex/issues/37420): Computer Use causes a `replayd` XPC reconnect loop and ~90% CPU while idle
- [#30503](https://github.com/openai/codex/issues/30503): Computer Use helper keeps ReplayKit active
- [#35659](https://github.com/openai/codex/issues/35659): ScreenCaptureKit stream not released
- [#51035](https://github.com/openai/codex/issues/51035): Appshots capture timeout

Symptoms:

- `/usr/libexec/replayd` long-running 70–90% CPU
- `SkyComputerUseService` 15–20% CPU
- Heat, lag and battery drain
- Killing `replayd` alone does not help

Temporary mitigation:

```bash
pkill -x SkyComputerUseService
```

More drastic, disables Computer Use until reauthorized:

```bash
tccutil reset ScreenCapture com.openai.sky.CUAService
```

Quitting and reopening ChatGPT/Codex also clears the loop.

## Computer Use missing

Issues:

- [#52191](https://github.com/openai/codex/issues/52191)
- [#43801](https://github.com/openai/codex/issues/43801)
- [#45696](https://github.com/openai/codex/issues/45696)
- [#45671](https://github.com/openai/codex/issues/45671)

User-side workaround:

1. Make sure `marketplaces.openai-bundled.source` matches the active `CODEX_HOME/.tmp/bundled-marketplaces/openai-bundled`.
2. Remove any generated disabled fallback:
   ```toml
   [mcp_servers.cua_repl]
   command = "/Applications/ChatGPT.app/Contents/MacOS/ChatGPT"
   enabled = false
   ```
3. Reinstall plugins:
   ```bash
   codex plugin remove computer-use@openai-bundled
   codex plugin remove unified-computer-use@openai-bundled
   codex plugin add computer-use@openai-bundled
   codex plugin add unified-computer-use@openai-bundled
   ```
4. Fully quit and reopen ChatGPT/Codex.
5. Check:
   ```bash
   codex mcp list | grep cua_repl
   ```

## Wallpaper memory

| Setup | RSS |
|---|---:|
| Dynamic desktop + lock screen Sonoma | ~147MB active |
| Static Sonoma image | ~84MB settled |
| Static solid color | Usually lower |

Keep `WallpaperAgent` enabled. Dynamic lock screen needs `WallpaperVideoExtension`.
