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

const COUNTER_VOLUME_DB := 0.0  # 読み勝ちの当たりは打撃音にベルの余韻を重ねる

var _players: Dictionary = {}


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
		c.pitch_scale = 1.0 + 0.05 * mini(hit_count - 1, 5)
		c.volume_db = COUNTER_VOLUME_DB
		c.play()


func play_win() -> void:
	var p: AudioStreamPlayer = _players["win"]
	p.pitch_scale = 1.0
	p.play()
