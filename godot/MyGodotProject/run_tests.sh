#!/bin/sh
# GUT をヘッドレスで実行する。失敗時は非0で終了。
# 新しい class_name を認識させるため、先に --import でグローバルクラスキャッシュを更新する。
cd "$(dirname "$0")" || exit 1
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . --import >/dev/null 2>&1
/Applications/Godot.app/Contents/MacOS/Godot --headless --path . -s addons/gut/gut_cmdln.gd 2>&1 | grep -v "is now available"
exit ${PIPESTATUS:-$?}
