class_name FighterPose
## FighterCore の状態から「四角形をどう変形させるか」を計算する純粋関数。
## 絵を差し替えるまでの仮アニメだが、発生・持続・硬直が目で分かることを目的にする。

const BODY_W := Moves.BODY_HALF_WIDTH * 2
const BODY_H := 160.0
const CROUCH_H := 100.0
const LOW_KICK_H := 130.0
const DOWN_H := 40.0
const LIMB_THICKNESS := 26.0
const THROW_THICKNESS := 60.0
const LEAN_BACK := 10.0
const LEAN_FORWARD := 14.0
const HITSTUN_TILT := -12.0  # 度。後ろに傾く

## 技ごとの手足の高さ（足元からの割合）
const LIMB_HEIGHT := {
	Moves.Kind.HIGH: 0.72,
	Moves.Kind.LOW: 0.18,
	Moves.Kind.THROW: 0.45,
}


## 戻り値:
##   body_w, body_h: 胴体の大きさ
##   lean_x: 胴体の前後オフセット（+ が向いている方向）
##   tilt: 胴体の傾き（度、+ が facing 方向へ倒れる）
##   phase: 技の段階 "" / "startup" / "active" / "recovery"
##   limb: {visible, length, thickness, y, forward} 手足の矩形。y は足元からの高さ(負)
static func compute(core: FighterCore) -> Dictionary:
	var pose := {
		"body_w": BODY_W, "body_h": BODY_H, "lean_x": 0.0, "tilt": 0.0,
		"phase": "", "limb": {"visible": false, "length": 0.0, "thickness": LIMB_THICKNESS, "y": 0.0},
	}
	match core.state:
		FighterCore.State.CROUCH:
			pose.body_h = CROUCH_H
		FighterCore.State.DOWN:
			pose.body_h = DOWN_H
			pose.body_w = BODY_W * 2
		FighterCore.State.HITSTUN:
			pose.tilt = HITSTUN_TILT * core.facing
			pose.lean_x = -6.0 * core.facing
		FighterCore.State.WALK:
			pose.body_h = BODY_H - 4.0 * absf(sin(core.frame * 0.4))
		FighterCore.State.ATTACK:
			_apply_attack(core, pose)
	return pose


static func _apply_attack(core: FighterCore, pose: Dictionary) -> void:
	var reach: float = Moves.DATA[core.move].reach
	var phase := core.attack_phase()
	var t := core.phase_progress()
	pose.phase = phase
	var limb: Dictionary = pose.limb
	limb.visible = true
	limb.y = -BODY_H * LIMB_HEIGHT[core.move]
	if core.move == Moves.Kind.LOW:
		pose.body_h = LOW_KICK_H
	if core.move == Moves.Kind.THROW:
		limb.thickness = THROW_THICKNESS
	match phase:
		"startup":
			# 構え: 後ろに引きながら手足を少しずつ出す
			limb.length = reach * 0.3 * t
			pose.lean_x = -LEAN_BACK * (1.0 - t * 0.5) * core.facing
		"active":
			limb.length = reach
			pose.lean_x = LEAN_FORWARD * core.facing
		"recovery":
			# 隙: 伸びきった手足をゆっくり戻す
			limb.length = reach * (1.0 - t)
			pose.lean_x = LEAN_FORWARD * (1.0 - t) * core.facing
