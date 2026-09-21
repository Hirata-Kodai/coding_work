# キャラクターモデル

- `character_t_pose.fbx`: Tripo（画像→3D、HD v2.5、リメッシュ 15,000 面）で生成した T ポーズモデルを Mixamo で自動リグしたもの（With Skin）
- `*.fbx`（それ以外）: Mixamo のアニメーション（Without Skin, 30fps, In Place）。骨格は本体と同一なので `Fighter3DView` がそのままライブラリに取り込む
- `textures/`: Tripo の OBJ 書き出しに同梱されていたテクスチャ（1k）。Mixamo 経由で失われるため `Fighter3DView` がマテリアルとして再適用する

`Fighter3DView` は取り込み時に Hips の位置トラックから前後左右の移動を消す（技の踏み込みで判定とズレるため）。
クリップを差し替えたら、`scratchpad` の実測スクリプトと同じ要領で手足の到達距離と impact の秒を測り直し、
`moves.gd` の reach と `fighter_anim.gd` の start/impact/end を更新する。

どのクリップをどの状態に使うかは `scripts/fighter_anim.gd` の `CLIPS` を参照。
