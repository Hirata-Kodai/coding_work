class_name HitboxDebug
extends Node2D
## F1 で切り替える当たり判定の可視化。MatchCore の判定をそのまま矩形で描く。
## 緑: 食らい判定、赤: 攻撃判定（持続中）、赤枠: 攻撃判定（発生中の予告）。

const GROUND_Y := 520.0
const STAND_H := 170.0
const CROUCH_H := 100.0
const DOWN_H := 130.0  # ダウンは Stunned（よろけ）クリップなので立ち姿に近い
const BOX_H := 30.0
const LIMB_HEIGHT := {Moves.Kind.HIGH: 0.7, Moves.Kind.LOW: 0.15, Moves.Kind.THROW: 0.5}

var _match: MatchCore


func _ready() -> void:
	visible = false


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_hitbox"):
		visible = not visible


func update_from(match_core: MatchCore) -> void:
	_match = match_core
	if visible:
		queue_redraw()


func _draw() -> void:
	if _match == null:
		return
	for core in [_match.p1, _match.p2]:
		_draw_hurtbox(core)
		_draw_attack(core)


func _draw_hurtbox(core: FighterCore) -> void:
	var h := STAND_H
	match core.state:
		FighterCore.State.CROUCH:
			h = CROUCH_H
		FighterCore.State.DOWN:
			h = DOWN_H
	var w := Moves.BODY_HALF_WIDTH * 2
	var rect := Rect2(core.hurtbox_x() - Moves.BODY_HALF_WIDTH, GROUND_Y - h, w, h)
	var color := Color(0.2, 1.0, 0.3, 0.25)
	if core.is_invulnerable():
		color = Color(0.5, 0.5, 1.0, 0.25)
	draw_rect(rect, color)
	draw_rect(rect, color.lightened(0.3), false, 2.0)


func _draw_attack(core: FighterCore) -> void:
	var phase := core.attack_phase()
	if phase != "startup" and phase != "active":
		return
	var reach: float = Moves.DATA[core.move].reach
	var near := core.x + core.facing * Moves.BODY_HALF_WIDTH
	var x0 := minf(near, near + core.facing * reach)
	var limb_h: float = LIMB_HEIGHT[core.move]
	var y: float = GROUND_Y - STAND_H * limb_h - BOX_H / 2
	var rect := Rect2(x0, y, reach, BOX_H)
	if phase == "active":
		draw_rect(rect, Color(1.0, 0.2, 0.2, 0.5))
	draw_rect(rect, Color(1.0, 0.3, 0.3, 0.9), false, 2.0)
