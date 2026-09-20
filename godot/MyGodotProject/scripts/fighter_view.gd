class_name FighterView
extends Node2D
## FighterCore の状態を四角形で描く。姿勢の計算は FighterPose に任せ、ここは矩形に流すだけ。

@export var body_color := Color(0.35, 0.65, 1.0)
@export var show_hitbox := false  # デバッグ用: 持続フレーム中の攻撃判定を赤く重ねる

var _pivot: Node2D  # 足元を原点にした回転軸
var _body: ColorRect
var _limb: ColorRect
var _hitbox: ColorRect
var _flash_frames := 0


func _ready() -> void:
	_pivot = Node2D.new()
	add_child(_pivot)
	_limb = ColorRect.new()
	_pivot.add_child(_limb)
	_body = ColorRect.new()
	_body.color = body_color
	_pivot.add_child(_body)
	_hitbox = ColorRect.new()
	_hitbox.color = Color(1.0, 0.3, 0.2, 0.5)
	_hitbox.visible = false
	add_child(_hitbox)


## 2フレームだけ白く塗る。
func flash(frames: int = 2) -> void:
	_flash_frames = frames


func sync(core: FighterCore) -> void:
	position.x = core.x
	var pose := FighterPose.compute(core)

	_pivot.position.x = pose.lean_x
	_pivot.rotation_degrees = pose.tilt
	_body.size = Vector2(pose.body_w, pose.body_h)
	_body.position = Vector2(-pose.body_w / 2, -pose.body_h)
	_body.color = _body_color_for(core, pose)

	var limb: Dictionary = pose.limb
	_limb.visible = limb.visible
	if limb.visible:
		var half: float = pose.body_w / 2.0
		var length: float = limb.length
		var x0: float = half if core.facing > 0 else -half - length
		_limb.position = Vector2(x0, limb.y - limb.thickness / 2)
		_limb.size = Vector2(length, limb.thickness)
		_limb.color = _limb_color_for(pose.phase)

	_hitbox.visible = show_hitbox and core.is_attack_active()
	if _hitbox.visible:
		var reach: float = Moves.DATA[core.move].reach
		var x0 := Moves.BODY_HALF_WIDTH if core.facing > 0 else -Moves.BODY_HALF_WIDTH - reach
		_hitbox.position = Vector2(x0, limb.y - 15)
		_hitbox.size = Vector2(reach, 30)


func _body_color_for(core: FighterCore, pose: Dictionary) -> Color:
	if _flash_frames > 0:
		_flash_frames -= 1
		return Color.WHITE
	var c := body_color
	if core.hp <= CombatRules.COMEBACK_HP:
		c = c.lerp(Color.RED, 0.4)
	if core.is_invulnerable() and int(core.invuln_frames / 3.0) % 2 == 0:
		c.a = 0.35  # 起き上がり無敵は点滅で示す
	match core.state:
		FighterCore.State.HITSTUN, FighterCore.State.DOWN:
			return c.darkened(0.4)
	match pose.phase:
		"startup":
			return c.lightened(0.35)  # 構えは明るく: 読める合図
		"recovery":
			return c.darkened(0.25)  # 隙は暗く: 殴れる合図
	return c


func _limb_color_for(phase: String) -> Color:
	match phase:
		"active":
			return Color(1.0, 0.95, 0.5)  # 判定中は目立つ黄色
		"startup":
			return body_color.lightened(0.5)
	return body_color.darkened(0.15)
