class_name Sfx
extends Node
## 効果音。技の種類ごとに AudioStreamPlayer を1つ持ち、連続ヒット数で音程を上げる。

## 打撃音全体の音程。1.0 が素材そのまま。連続ヒットの上昇分はこれに掛かる。
const BASE_PITCH := 3.0

const STREAMS := {
	"high": "res://assets/sfx/hit_high.ogg",
	"low": "res://assets/sfx/hit_low.ogg",
	"throw": "res://assets/sfx/hit_throw.ogg",
	"win": "res://assets/sfx/win.ogg",
	"counter": "res://assets/sfx/counter.ogg",
}

const COUNTER_VOLUME_DB := 0.0
const COUNTER_PITCH := 0.5  # glass_004 はそのままだと高すぎるので下げる
const COUNTER_TAIL := 0.3  # 余韻はこの秒数でフェードアウトして切る

var _players: Dictionary = {}
var _counter_fade: Tween


func _ready() -> void:
	for kind in STREAMS:
		var p := AudioStreamPlayer.new()
		p.stream = load(STREAMS[kind])
		p.volume_db = -3.0
		add_child(p)
		_players[kind] = p


func player_for(kind: String) -> AudioStreamPlayer:
	return _players.get(kind)


## hit_count は連続何発目か(1始まり)。音程は CombatRules.pitch_scale と同じカウンタで決まる。
## counter が true（3すくみに勝った当たり）ならベルの余韻を重ねる。
func play_hit(kind: String, hit_count: int, counter: bool = false) -> void:
	var p: AudioStreamPlayer = _players.get(kind)
	if p == null:
		return
	p.pitch_scale = BASE_PITCH * CombatRules.pitch_scale(hit_count)
	p.play()
	if counter:
		var c: AudioStreamPlayer = _players["counter"]
		c.pitch_scale = COUNTER_PITCH + 0.04 * mini(hit_count - 1, 5)
		c.volume_db = COUNTER_VOLUME_DB
		c.play()
		# ピッチを下げると再生が伸びて余韻が長くなるので、フェードで切る
		if _counter_fade != null:
			_counter_fade.kill()
		_counter_fade = create_tween()
		_counter_fade.tween_property(c, "volume_db", -40.0, COUNTER_TAIL).set_delay(0.1)
		_counter_fade.tween_callback(c.stop)


func play_win() -> void:
	var p: AudioStreamPlayer = _players["win"]
	p.pitch_scale = 1.0
	p.play()
