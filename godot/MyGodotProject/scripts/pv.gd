extends Node2D
## PV の再生。PvScript の台本どおりに MatchCore を進め、演出を鳴らす。
## 入力は Input を読まず台本から渡すので、録画しても毎回同じ映像になる。

const PX_PER_M := Fighter3DView.PX_PER_M
const SHAKE_AMPLITUDE := 8.0
const SHAKE_FRAMES := 6
const BASE_CAMERA_SIZE := 6.48
const BASE_CAMERA_Y := 1.96
const CAMERA_LERP := 0.12
const TITLE := "ドパガキ 2D格闘"

@onready var _camera: Camera3D = $World/Camera3D
@onready var _view1: Fighter3DView = $World/Fighter1
@onready var _view2: Fighter3DView = $World/Fighter2
@onready var _hud: PvHud = $PvHud
@onready var _sfx: Sfx = $Sfx

var _match: MatchCore
var _seg_index := 0
var _seg_frame := 0  # 区間内の映像フレーム
var _seg_step := 0  # 区間内の試合フレーム
var _slow_counter := 0
var _hitstop_frames := 0
var _done := false


func _ready() -> void:
	_match = MatchCore.new(PvScript.STAGE_WIDTH)
	_match.time_left_frames = Moves.ROUND_FRAMES
	_enter_segment()


func _physics_process(_delta: float) -> void:
	if _done:
		return
	var seg: Dictionary = PvScript.SEGMENTS[_seg_index]
	_advance_match(seg)
	_update_caption(seg)
	_update_camera(seg)
	_sync_views()
	_seg_frame += 1
	if _seg_frame >= PvScript.segment_frames(seg):
		_seg_index += 1
		if _seg_index >= PvScript.SEGMENTS.size():
			_finish()
			return
		_enter_segment()


## ヒットストップ中は試合を進めない。slow の分だけ映像フレームを費やして1試合フレーム進む。
func _advance_match(seg: Dictionary) -> void:
	if seg.steps == 0 or _seg_step >= seg.steps:
		return
	if _hitstop_frames > 0:
		_hitstop_frames -= 1
		return
	_slow_counter -= 1
	if _slow_counter > 0:
		return
	_slow_counter = seg.slow
	var events := _match.step(
		PvScript.input_at(seg, _seg_step, 1), PvScript.input_at(seg, _seg_step, 2)
	)
	_seg_step += 1
	for ev in events:
		if ev.type == "hit":
			_on_hit(ev)


func _on_hit(ev: Dictionary) -> void:
	_hitstop_frames = maxi(_hitstop_frames, ev.hitstop)
	_shake()
	var target: Fighter3DView = _view2 if ev.target == 2 else _view1
	target.flash(2)
	DamageNumber.spawn(self, Vector2(ev.x, 400.0), ev.damage, ev.hit_count)
	_sfx.play_hit(ev.kind, ev.hit_count, ev.counter)


func _shake() -> void:
	var offset := Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * SHAKE_AMPLITUDE
	_camera.h_offset = offset.x / PX_PER_M
	_camera.v_offset = -offset.y / PX_PER_M
	var tween := create_tween().set_parallel(true)
	tween.tween_property(_camera, "h_offset", 0.0, SHAKE_FRAMES / 60.0)
	tween.tween_property(_camera, "v_offset", 0.0, SHAKE_FRAMES / 60.0)


## 拡大時は両者の中間を追い、背景の外が映らないよう端で止める。
func _update_camera(seg: Dictionary) -> void:
	var zoom: float = seg.get("zoom", 1.0)
	var size := BASE_CAMERA_SIZE / zoom
	_camera.size = lerpf(_camera.size, size, CAMERA_LERP)
	var mid := (_match.p1.x + _match.p2.x) / 2.0 / PX_PER_M
	var half := _camera.size * (1152.0 / 648.0) / 2.0
	var target := clampf(mid, half, PvScript.STAGE_WIDTH / PX_PER_M - half)
	_camera.position.x = lerpf(_camera.position.x, target, CAMERA_LERP)
	# 寄るほどカメラを下げて足元が切れないようにする
	var y := minf(BASE_CAMERA_Y, _camera.size * 0.46)
	_camera.position.y = lerpf(_camera.position.y, y, CAMERA_LERP)


func _update_caption(seg: Dictionary) -> void:
	var text := ""
	for c in seg.get("captions", []):
		if _seg_frame >= c[0]:
			text = c[1]
	_hud.set_caption(text)


func _enter_segment() -> void:
	var seg: Dictionary = PvScript.SEGMENTS[_seg_index]
	if seg.has("setup"):
		PvScript.apply_setup(_match, seg.setup)
	_seg_frame = 0
	_seg_step = 0
	_slow_counter = 1
	_hitstop_frames = 0
	_hud.set_bars_visible(seg.steps > 0)
	if seg.name == "outro":
		_hud.show_title(TITLE)


func _sync_views() -> void:
	_view1.sync(_match.p1)
	_view2.sync(_match.p2)
	_hud.set_hp(_match.p1.hp, _match.p2.hp)


func _finish() -> void:
	_done = true
	get_tree().quit()
