# Scripts

所有脚本先 dry-run，再 apply。

## launchd 清理

```bash
./disable-apple-residual.sh --dry-run
./disable-apple-residual.sh --apply
./disable-apple-residual.sh --enable   # 回滚
```

同理适用于：

- `disable-apple-extra.sh`
- `disable-spotlight-sharing.sh`
- `disable-extra-launchd.sh`

## 壁纸

```bash
./set-wallpaper.py "/System/Library/Desktop Pictures/Sonoma.heic"
./set-wallpaper.py --restore
```

## Chrome

`chrome/chrome-optimized-runner`：限制 GPU 预算，禁用语音识别。  
`chrome/chrome-low-gpu-runner`：禁用 GPU，极低显存但 CPU 会上升。

用法：

```bash
./chrome/chrome-optimized-runner
```

需要先完全退出 Chrome，否则 macOS 会把启动请求交给已有进程。
