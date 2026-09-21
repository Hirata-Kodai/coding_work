class_name FighterAnim
## FighterCore の状態から「どのクリップの何秒目を表示するか」を決める純粋関数。
## AnimationPlayer には自動再生させず、毎フレーム seek するので、
## ヒットストップで止まり、技のフレームデータと必ず同期する。

const DIR := "res://assets/models/character/"

## start/end はクリップ内で使う区間（秒）。Mixamo のクリップは前後に余白があるので刈り込む。
## 攻撃クリップの impact は手足が最も前に出る瞬間（骨の位置を実測した値）。
## 発生フレームが start→impact、持続と硬直が impact→end に対応するので、判定開始と見た目が一致する。
const CLIPS := {
	"idle": {"file": DIR + "Idle.fbx", "start": 0.0, "end": 8.3, "loop": true},
	"walk": {"file": DIR + "Walking.fbx", "start": 0.0, "end": 1.0, "loop": true},
	"crouch": {"file": DIR + "Idle Crouching Aiming.fbx", "start": 0.0, "end": 2.1, "loop": true},
	"high": {"file": DIR + "Lead Jab.fbx", "start": 0.2, "impact": 0.4, "end": 0.9, "loop": false},
	"low": {"file": DIR + "Leg Sweep.fbx", "start": 0.3, "impact": 0.9, "end": 1.4, "loop": false},
	"throw": {"file": DIR + "Throw Object.fbx", "start": 0.2, "impact": 0.6, "end": 1.4, "loop": false},
	"hit": {"file": DIR + "Hit To Body.fbx", "start": 0.1, "end": 0.9, "loop": false},
	"down": {"file": DIR + "Stunned.fbx", "start": 0.0, "end": 2.0, "loop": false},
	"getup": {"file": DIR + "Getting Up.fbx", "start": 0.4, "end": 2.4, "loop": false},
}

const MOVE_CLIP := {
	Moves.Kind.HIGH: "high",
	Moves.Kind.LOW: "low",
	Moves.Kind.THROW: "throw",
}


## 戻り値: {"clip": String, "time": float}
static func select(core: FighterCore) -> Dictionary:
	match core.state:
		FighterCore.State.WALK:
			return _loop("walk", core.frame)
		FighterCore.State.CROUCH:
			return _loop("crouch", core.frame)
		FighterCore.State.ATTACK:
			return _attack(MOVE_CLIP[core.move], core)
		FighterCore.State.HITSTUN:
			return _stretch("hit", core.frame, Moves.HITSTUN_FRAMES)
		FighterCore.State.DOWN:
			# 前半は倒れる、後半は起き上がる
			@warning_ignore("integer_division")
			var half: int = Moves.DOWN_FRAMES / 2
			if core.frame < half:
				return _stretch("down", core.frame, half)
			return _stretch("getup", core.frame - half, Moves.DOWN_FRAMES - half)
	return _loop("idle", core.frame)


## 状態に入ってからの経過フレームで区間内をループ再生する。
static func _loop(clip: String, frame: int) -> Dictionary:
	var c: Dictionary = CLIPS[clip]
	var length: float = c.end - c.start
	return {"clip": clip, "time": c.start + fmod(frame / 60.0, length)}


## 発生を start→impact に、持続＋硬直を impact→end に対応付ける。
static func _attack(clip: String, core: FighterCore) -> Dictionary:
	var c: Dictionary = CLIPS[clip]
	var d: Dictionary = Moves.DATA[core.move]
	var startup: int = d.startup
	var total := Moves.total_frames(core.move)
	if core.frame < startup:
		return {"clip": clip, "time": lerpf(c.start, c.impact, float(core.frame) / float(startup))}
	var t := clampf(float(core.frame - startup) / float(total - 1 - startup), 0.0, 1.0)
	return {"clip": clip, "time": lerpf(c.impact, c.end, t)}


## total フレームの動作を区間全体に引き伸ばす（frame 0 が start、最終フレームが end）。
static func _stretch(clip: String, frame: int, total: int) -> Dictionary:
	var c: Dictionary = CLIPS[clip]
	var t := 0.0 if total <= 1 else clampf(float(frame) / float(total - 1), 0.0, 1.0)
	return {"clip": clip, "time": lerpf(c.start, c.end, t)}
