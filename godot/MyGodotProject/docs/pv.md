# PV の作り方

`scenes/pv.tscn` が 20 秒のダイジェスト PV。台本は `scripts/pv_script.gd`、再生は `scripts/pv.gd`。

入力を `Input` から読まず台本の辞書で渡し、`MatchCore` は固定タイムステップなので、
何度録っても完全に同じ映像になる。台本を直したら `./run_tests.sh` で
「キャプションどおりの出来事が実際に起きるか」が検証される。

## 録画

```sh
# 1. 60fps 固定で AVI (MJPEG + 音声) に書き出す。実時間より遅くても映像は 60fps になる
/Applications/Godot.app/Contents/MacOS/Godot --path . scenes/pv.tscn --write-movie /tmp/pv.avi

# 2. mp4 に変換（AVI は 1 分あたり約 350MB なので変換後に消す）
ffmpeg -i /tmp/pv.avi -c:v libx264 -preset slow -crf 19 -pix_fmt yuv420p -c:a aac -b:a 160k /tmp/pv.mp4
```

## 既知の問題

決着をノックダウン（投げ）にすると、KO 後に描画がそのフレームで固まる。
`MatchCore` が止まって被弾側が DOWN のまま動かなくなる状況で再現し、ロジックは
動き続けているのに画面だけ更新されない。本編でも投げで KO した直後の 2.5 秒が
同じ状態になる可能性があるため、別途調べる必要がある。
PV は下段で決着させることで回避している。
