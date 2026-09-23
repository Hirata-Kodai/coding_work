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

## 録画時の注意

**録画中は Godot のウィンドウを前面に出したまま、他のウィンドウを重ねない。**
隠れると macOS が描画を止め、スクリプトは動き続けているのに映像だけそのフレームで
固まる（凍結する位置は録画ごとに変わる）。録画後は数点フレームを抜き出して
固まっていないか確かめる:

```sh
for t in 1 5 9 13 17 19; do
  ffmpeg -y -loglevel error -i pv.mp4 -ss $t -frames:v 1 -vf scale=200:-1 /tmp/f$t.png
  echo -n "$t "; md5 -q /tmp/f$t.png
done   # 同じ md5 が続いたら凍結している
```

## 台本を書くときの注意

区間の途中で KO すると `MatchCore` が止まり、それ以降の区間で両者が固まったままになる。
見せ場の区間の `setup` で体力を戻しておくこと（`combo` 区間がその例）。
