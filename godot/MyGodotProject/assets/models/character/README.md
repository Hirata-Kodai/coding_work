# キャラクターモデル

- `character_t_pose.fbx`: Tripo（画像→3D、HD v2.5、リメッシュ 15,000 面）で生成した T ポーズモデルを Mixamo で自動リグしたもの（With Skin）
- `*.fbx`（それ以外）: Mixamo のアニメーション（Without Skin, 30fps, In Place）。骨格は本体と同一なので `Fighter3DView` がそのままライブラリに取り込む
- `textures/`: Tripo の OBJ 書き出しに同梱されていたテクスチャ（1k）。Mixamo 経由で失われるため `Fighter3DView` がマテリアルとして再適用する

どのクリップをどの状態に使うかは `scripts/fighter_anim.gd` の `CLIPS` を参照。
