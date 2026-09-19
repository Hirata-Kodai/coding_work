class_name CpuBrain
extends RefCounted
## CPU の行動ロジック。乱数で3すくみを選ぶだけ。レベル1〜5で「相手の技に勝つ手を返す確率」と
## 間合い管理の有無が変わる。人間と同じ入力辞書を返すので Main はどちらでも同じ扱いになる。

const LEVEL_PARAMS := {
	1: {"counter": 0.0, "range_aware": false, "spacing": false, "hold": 20},
	2: {"counter": 0.0, "range_aware": true, "spacing": false, "hold": 16},
	3: {"counter": 0.5, "range_aware": true, "spacing": false, "hold": 14},
	4: {"counter": 0.8, "range_aware": true, "spacing": false, "hold": 12},
	5: {"counter": 0.95, "range_aware": true, "spacing": true, "hold": 10},
}

var level: int
var _rng: RandomNumberGenerator
var _params: Dictionary
var _hold: int = 0  # 今の行動を続けるフレーム数
var _dir: int = 0
var _pending_attack: int = -1  # 次の decide で押す技


func _init(cpu_level: int, rng: RandomNumberGenerator = null) -> void:
	level = clampi(cpu_level, 1, 5)
	_params = LEVEL_PARAMS[level]
	_rng = rng if rng != null else RandomNumberGenerator.new()


## 与えられた技に勝つ技。
static func counter_move(kind: Moves.Kind) -> Moves.Kind:
	match kind:
		Moves.Kind.HIGH:
			return Moves.Kind.LOW
		Moves.Kind.LOW:
			return Moves.Kind.THROW
		_:
			return Moves.Kind.HIGH


func reset() -> void:
	_hold = 0
	_dir = 0
	_pending_attack = -1


func decide(me: FighterCore, opp: FighterCore) -> Dictionary:
	var input := FighterCore.empty_input()
	var opp_started_attack := opp.state == FighterCore.State.ATTACK and opp.frame == 0
	if _hold <= 0 or (opp_started_attack and _params.counter > 0.0):
		_plan(me, opp)
	_hold -= 1
	input.left = _dir < 0
	input.right = _dir > 0
	if _pending_attack != -1:
		input[Moves.DATA[_pending_attack].name] = true
		_pending_attack = -1  # 1フレームだけ押す
	return input


func _plan(me: FighterCore, opp: FighterCore) -> void:
	_hold = _params.hold
	var toward := 1 if opp.x > me.x else -1
	var gap := absf(opp.x - me.x) - Moves.BODY_HALF_WIDTH * 2

	# 相手が技を出した瞬間に勝つ手を返す
	if opp.state == FighterCore.State.ATTACK and _rng.randf() < _params.counter:
		_pending_attack = counter_move(opp.move)
		_dir = toward if gap > Moves.DATA[_pending_attack].reach else 0
		return

	var kind: int = _rng.randi_range(0, 2)
	if not _params.range_aware:
		_pending_attack = kind
		_dir = [-1, 0, 1][_rng.randi_range(0, 2)]
		return

	var reach: float = Moves.DATA[kind].reach
	if gap <= reach:
		_pending_attack = kind
		_dir = 0
		return
	# 届かない: 近づく。レベル5は相手の上段の間合いの外で一瞬待つこともある
	_pending_attack = -1
	if _params.spacing and gap < Moves.DATA[Moves.Kind.HIGH].reach + 20 and _rng.randf() < 0.3:
		_dir = -toward
	else:
		_dir = toward
