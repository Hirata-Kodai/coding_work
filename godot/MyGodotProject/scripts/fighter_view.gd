class_name FighterView
extends Node2D
## FighterCore の状態を四角形で描く。ロジックは持たない。

const BODY_W := Moves.BODY_HALF_WIDTH * 2
const BODY_H := 160.0
const CROUCH_H := 100.0
const DOWN_H := 40.0
const HITBOX_H := 30.0

@export var body_color := Color(0.35, 0.65, 1.0)

var _body: ColorRect
var _hitbox: ColorRect
var _flash_frames := 0


func _ready() -> void:
	_body = ColorRect.new()
	_body.color = body_color
	add_child(_body)
	_hitbox = ColorRect.new()
	_hitbox.color = Color(1.0, 0.3, 0.2, 0.7)
	_hitbox.visible = false
	add_child(_hitbox)


## 2フレームだけ白く塗る。
func flash(frames: int = 2) -> void:
	_flash_frames = frames


func sync(core: FighterCore) -> void:
	position.x = core.x
	var h := BODY_H
	match core.state:
		FighterCore.State.CROUCH:
			h = CROUCH_H
		FighterCore.State.DOWN:
			h = DOWN_H
	var w := BODY_W if core.state != FighterCore.State.DOWN else BODY_W * 2
	_body.size = Vector2(w, h)
	_body.position = Vector2(-w / 2, -h)

	if _flash_frames > 0:
		_flash_frames -= 1
		_body.color = Color.WHITE
	elif core.state == FighterCore.State.HITSTUN or core.state == FighterCore.State.DOWN:
		_body.color = body_color.darkened(0.4)
	elif core.hp <= CombatRules.COMEBACK_HP:
		_body.color = body_color.lerp(Color.RED, 0.4)
	else:
		_body.color = body_color

	# 攻撃判定の可視化（持続フレーム中のみ）
	_hitbox.visible = core.is_attack_active()
	if _hitbox.visible:
		var reach: float = Moves.DATA[core.move].reach
		var y := -BODY_H * 0.7
		if core.move == Moves.Kind.LOW:
			y = -BODY_H * 0.2
		elif core.move == Moves.Kind.THROW:
			y = -BODY_H * 0.45
		var x0 := Moves.BODY_HALF_WIDTH if core.facing > 0 else -Moves.BODY_HALF_WIDTH - reach
		_hitbox.position = Vector2(x0, y)
		_hitbox.size = Vector2(reach, HITBOX_H)
