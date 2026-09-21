extends Node2D
## ラウンドループと演出の発火。ゲームの進行は MatchCore に任せ、ここは
## 「入力を集めて渡す」「イベントを受けて演出する」「ラウンド間の遷移」だけを行う。

enum Phase { FIGHT, PLAY, KO, STREAK }

const STAGE_WIDTH := 1152.0
const GROUND_Y := 520.0
const FIGHT_FRAMES := 30  # 0.5秒
const KO_FRAMES := 90  # 1.5秒
const STREAK_FRAMES := 60  # 1秒
const SHAKE_AMPLITUDE := 6.0
const SHAKE_FRAMES := 6

@onready var _camera: Camera2D = $Camera2D
@onready var _camera3d: Camera3D = $World/Camera3D
@onready var _view1: Fighter3DView = $World/Fighter1
@onready var _view2: Fighter3DView = $World/Fighter2
@onready var _hud: Hud = $HUD
@onready var _sfx: Sfx = $Sfx
@onready var _hitbox_debug: HitboxDebug = $HitboxDebug

var _match: MatchCore
var _cpu: CpuBrain
var _phase := Phase.FIGHT
var _phase_frames := 0
var _hitstop_frames := 0
var _streak := 0
var _best := 0
var _last_result := 0  # 直前の試合の勝者


func _ready() -> void:
	_start_match()


func _physics_process(_delta: float) -> void:
	_phase_frames += 1
	match _phase:
		Phase.FIGHT:
			if _phase_frames >= FIGHT_FRAMES:
				_enter_phase(Phase.PLAY)
				_hud.set_message("")
		Phase.PLAY:
			_play_frame()
		Phase.KO:
			if _phase_frames >= KO_FRAMES:
				_enter_phase(Phase.STREAK)
		Phase.STREAK:
			if _phase_frames >= STREAK_FRAMES:
				_start_match()
	_sync_views()


func _play_frame() -> void:
	# ヒットストップ中は試合を進めない。演出と入力は生きている。
	if _hitstop_frames > 0:
		_hitstop_frames -= 1
		return
	var input1 := InputReader.read_p1()
	var input2 := _cpu.decide(_match.p2, _match.p1)
	for ev in _match.step(input1, input2):
		_handle_event(ev)


func _handle_event(ev: Dictionary) -> void:
	match ev.type:
		"hit":
			_on_hit(ev)
		"ko":
			_finish_match(ev.winner, "K.O.")
		"time_up":
			_finish_match(ev.winner, "TIME UP")


func _on_hit(ev: Dictionary) -> void:
	_hitstop_frames = maxi(_hitstop_frames, ev.hitstop)
	_shake()
	var target: Fighter3DView = _view2 if ev.target == 2 else _view1
	target.flash(2)
	_sfx.play_hit(ev.kind, ev.hit_count)
	DamageNumber.spawn(self, Vector2(ev.x, GROUND_Y - 120), ev.damage, ev.hit_count)


func _shake() -> void:
	var offset := Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized() * SHAKE_AMPLITUDE
	_camera.offset = offset
	# 3D カメラは m 単位、2D の y は下向きなので符号を反転
	_camera3d.h_offset = offset.x / Fighter3DView.PX_PER_M
	_camera3d.v_offset = -offset.y / Fighter3DView.PX_PER_M
	var tween := create_tween().set_parallel(true)
	tween.tween_property(_camera, "offset", Vector2.ZERO, SHAKE_FRAMES / 60.0)
	tween.tween_property(_camera3d, "h_offset", 0.0, SHAKE_FRAMES / 60.0)
	tween.tween_property(_camera3d, "v_offset", 0.0, SHAKE_FRAMES / 60.0)


func _finish_match(winner: int, message: String) -> void:
	_last_result = winner
	if winner == 1:
		_sfx.play_win()
	_hud.set_message(message)
	_enter_phase(Phase.KO)


func _start_match() -> void:
	# 連勝更新は KO → STREAK の表示前ではなく、次の試合開始時にまとめて反映する
	if _last_result == 1:
		_streak += 1
		_best = maxi(_best, _streak)
	elif _last_result != 0 or _match != null:
		_streak = 0
	_last_result = 0
	_match = MatchCore.new(STAGE_WIDTH)
	_cpu = CpuBrain.new(mini(_streak + 1, 5))
	_hitstop_frames = 0
	_hud.set_streak(_streak, _best)
	_hud.set_message("FIGHT")
	_enter_phase(Phase.FIGHT)


func _enter_phase(phase: Phase) -> void:
	_phase = phase
	_phase_frames = 0
	if phase == Phase.STREAK:
		_hud.set_message("%d WIN STREAK" % (_streak + 1) if _last_result == 1 else "BEST: %d" % _best)


func _sync_views() -> void:
	_view1.sync(_match.p1)
	_view2.sync(_match.p2)
	_hitbox_debug.update_from(_match)
	_hud.set_hp(_match.p1.hp, _match.p2.hp)
	_hud.set_time(_match.time_left_frames / 60.0)
