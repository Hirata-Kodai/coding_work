class_name Fighter3DView
extends Node3D
## Mixamo でリグ付けしたキャラで FighterCore を描く。
## 座標は 1 m = 100 px で MatchCore の x をそのまま使う。アニメは FighterAnim の指示どおり seek するだけ。

const CHARACTER := "res://assets/models/character/character_t_pose.fbx"
const TEXTURES := "res://assets/models/character/textures/"
const LIBRARY := "fighter"
const PX_PER_M := 100.0
const TARGET_HEIGHT_M := 1.75

## 2体を見分けるための薄い色。p1 は青系、p2 は赤系。
@export var tint := Color(0.35, 0.65, 1.0, 0.2)

var _model: Node3D
var _ap: AnimationPlayer
var _mesh: MeshInstance3D
var _overlay := StandardMaterial3D.new()
var _flash_frames := 0


func _ready() -> void:
	_model = load(CHARACTER).instantiate()
	add_child(_model)
	_mesh = _model.find_children("*", "MeshInstance3D", true, false)[0]
	_ap = _model.find_child("AnimationPlayer", true, false)
	_ap.speed_scale = 0.0  # 自動では進めない。毎フレーム seek する

	# Mixamo の FBX は cm 単位のまま入ってきて極端に小さいので、身長で正規化する
	var height: float = _mesh.get_aabb().size.y
	_model.scale = Vector3.ONE * (TARGET_HEIGHT_M / height)

	_ap.add_animation_library(LIBRARY, _build_library())
	_mesh.set_surface_override_material(0, _build_material())

	_overlay.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_overlay.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_overlay.albedo_color = tint
	_mesh.material_overlay = _overlay


## Mixamo 経由で失われたテクスチャを Tripo の書き出しから戻す。
func _build_material() -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_texture = load(TEXTURES + "basecolor.jpg")
	m.normal_enabled = true
	m.normal_texture = load(TEXTURES + "normal.jpg")
	m.roughness_texture = load(TEXTURES + "roughness.jpg")
	return m


## 各アニメ FBX から mixamo_com クリップを取り出して1つのライブラリにまとめる。
## 骨格が同一なのでトラックのパス (Skeleton3D:mixamorig_*) はそのまま使える。
func _build_library() -> AnimationLibrary:
	var lib := AnimationLibrary.new()
	for clip_name in FighterAnim.CLIPS:
		var src: Node = load(FighterAnim.CLIPS[clip_name].file).instantiate()
		var src_ap: AnimationPlayer = src.find_child("AnimationPlayer", true, false)
		var anim: Animation = src_ap.get_animation("mixamo_com").duplicate()
		anim.loop_mode = Animation.LOOP_NONE
		_strip_horizontal_root_motion(anim)
		lib.add_animation(clip_name, anim)
		src.free()
	return lib


## 腰の位置トラックから前後左右の移動を消して高さだけ残す。
## 技の踏み込みやダウンの後退はキャラの位置 (MatchCore の x) と二重になって判定とズレるため。
static func _strip_horizontal_root_motion(anim: Animation) -> void:
	var track := anim.find_track("Skeleton3D:mixamorig_Hips", Animation.TYPE_POSITION_3D)
	if track == -1:
		return
	var first: Vector3 = anim.track_get_key_value(track, 0)
	for k in anim.track_get_key_count(track):
		var v: Vector3 = anim.track_get_key_value(track, k)
		anim.track_set_key_value(track, k, Vector3(first.x, v.y, first.z))


## 2フレームだけ白く塗る。
func flash(frames: int = 2) -> void:
	_flash_frames = frames


func sync(core: FighterCore) -> void:
	position.x = core.x / PX_PER_M
	rotation.y = deg_to_rad(90.0) * core.facing  # Mixamo のキャラは +Z を向いている

	var a := FighterAnim.select(core)
	var clip: String = LIBRARY + "/" + a.clip
	if _ap.current_animation != clip:
		_ap.play(clip)
	_ap.seek(a.time, true)

	_model.visible = not (core.is_invulnerable() and int(core.invuln_frames / 3.0) % 2 == 0)
	_overlay.albedo_color = _overlay_color_for(core)


func _overlay_color_for(core: FighterCore) -> Color:
	if _flash_frames > 0:
		_flash_frames -= 1
		return Color(1, 1, 1, 1)
	var c := tint
	if core.hp <= CombatRules.COMEBACK_HP:
		c = Color(1.0, 0.15, 0.1, 0.45)
	match core.state:
		FighterCore.State.HITSTUN, FighterCore.State.DOWN:
			return Color(0, 0, 0, 0.45)
	match core.attack_phase():
		"startup":
			return Color(1, 1, 1, 0.35)  # 構えは明るく: 読める合図
		"recovery":
			return Color(0, 0, 0, 0.3)  # 隙は暗く: 殴れる合図
	return c
