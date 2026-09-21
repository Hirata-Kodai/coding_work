class_name Bgm
extends Node
## BGM。起動時に鳴らし始め、試合間でも止めない（企画書「試合と試合の間で止めず、鳴らし続ける」）。

const STREAM := "res://assets/bgms/fight_looped.wav"
const VOLUME_DB := -10.0  # 効果音より控えめに

var _player: AudioStreamPlayer
var started := false  # play() を呼んだか。ヘッドレス（音声ドライバなし）では playing が立たないのでテスト用


func _ready() -> void:
	_player = AudioStreamPlayer.new()
	_player.stream = load(STREAM)
	_player.volume_db = VOLUME_DB
	_player.bus = "Master"
	add_child(_player)
	_player.play()
	started = true


func is_playing() -> bool:
	return _player.playing


func is_looping() -> bool:
	var s := _player.stream as AudioStreamWAV
	return s != null and s.loop_mode != AudioStreamWAV.LOOP_DISABLED


func _exit_tree() -> void:
	# 終了時に再生中のままだと AudioStreamPlaybackWAV がリークとして報告される
	_player.stop()
