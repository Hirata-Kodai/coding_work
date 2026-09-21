class_name MatchCore
extends RefCounted
## 試合1本の進行。2体の FighterCore を固定ステップで進め、当たり判定と勝敗を決める。
## シーンに依存しない。演出は step() が返すイベントを見て Main が行う。

var p1: FighterCore
var p2: FighterCore
var tick: int = 0
var time_left_frames: int = Moves.ROUND_FRAMES
var finished: bool = false
var winner: int = 0  # 1, 2, 0 = 引き分け／未決着

var _stage_width: float


func _init(stage_width: float) -> void:
	_stage_width = stage_width
	p1 = FighterCore.new(stage_width / 3.0, 1)
	p2 = FighterCore.new(stage_width * 2.0 / 3.0, -1)
	for f in [p1, p2]:
		f.min_x = Moves.BODY_HALF_WIDTH
		f.max_x = stage_width - Moves.BODY_HALF_WIDTH


func step(input1: Dictionary, input2: Dictionary) -> Array:
	if finished:
		return []
	var events := []
	p1.step(input1)
	p2.step(input2)
	_separate_bodies()
	_update_facing()
	events.append_array(_resolve_attacks())
	tick += 1
	time_left_frames -= 1
	events.append_array(_check_end())
	return events


func get_state() -> Dictionary:
	return {
		"tick": tick,
		"p1": p1.get_state_dict(),
		"p2": p2.get_state_dict(),
		"time_left": time_left_frames / 60.0,
	}


## 体が重ならないよう、めり込んだ分を等分に押し返す。
func _separate_bodies() -> void:
	var min_gap := Moves.BODY_HALF_WIDTH * 2
	var gap := absf(p2.x - p1.x)
	if gap >= min_gap:
		return
	var push := (min_gap - gap) / 2.0
	var left := p1 if p1.x <= p2.x else p2
	var right := p2 if left == p1 else p1
	left.x = clampf(left.x - push, left.min_x, left.max_x)
	right.x = clampf(right.x + push, right.min_x, right.max_x)
	# 壁際で片方が動けなかった場合はもう片方が全部引き受ける
	if right.x - left.x < min_gap:
		if left.x <= left.min_x:
			right.x = left.x + min_gap
		else:
			left.x = right.x - min_gap


func _update_facing() -> void:
	p1.facing = 1 if p1.x <= p2.x else -1
	p2.facing = -p1.facing


## 両者の攻撃を同時に判定してから適用する（相打ちのため）。
func _resolve_attacks() -> Array:
	var c1 := _connects(p1, p2)
	var c2 := _connects(p2, p1)
	var events := []
	if c1 and c2:
		# 同フレームで両方届いた。3すくみで勝つ方だけ通す。同じ技なら相打ち。
		match CombatRules.compare(p1.move, p2.move):
			CombatRules.Outcome.WIN:
				c2 = false
			CombatRules.Outcome.LOSE:
				c1 = false
			CombatRules.Outcome.TRADE:
				events.append(_apply_hit(p1, p2, 2, true))
				events.append(_apply_hit(p2, p1, 1, true))
				return events
	if c1:
		events.append(_apply_hit(p1, p2, 2, false))
	if c2:
		events.append(_apply_hit(p2, p1, 1, false))
	return events


## attacker の攻撃がこのフレームで defender に届くか。
func _connects(attacker: FighterCore, defender: FighterCore) -> bool:
	if not attacker.is_attack_active() or attacker.has_hit:
		return false
	var near := attacker.x + attacker.facing * Moves.BODY_HALF_WIDTH
	var far := attacker.attack_front_x()
	var lo := minf(near, far)
	var hi := maxf(near, far)
	var hx := defender.hurtbox_x()
	if hx + Moves.BODY_HALF_WIDTH < lo or hx - Moves.BODY_HALF_WIDTH > hi:
		return false
	if defender.is_invulnerable():
		return false
	match defender.state:
		FighterCore.State.CROUCH:
			if CombatRules.crouch_avoids(attacker.move):
				return false
		FighterCore.State.DOWN:
			if attacker.move == Moves.Kind.THROW:
				return false
		FighterCore.State.ATTACK:
			# 相手も技の最中。負ける技は空振りで、相手の技はそのまま進む。
			if CombatRules.compare(attacker.move, defender.move) == CombatRules.Outcome.LOSE:
				attacker.has_hit = true
				return false
	return true


func _apply_hit(attacker: FighterCore, defender: FighterCore, target: int, trade: bool) -> Dictionary:
	var data: Dictionary = Moves.DATA[attacker.move]
	var hit_count: int = defender.combo_count + 1
	var dmg := CombatRules.damage(data.damage, hit_count, attacker.hp)
	var knockdown: bool = trade or attacker.move == Moves.Kind.THROW
	# 相手が技の最中（負ける技を出している、または空振りの硬直中）に当てた = 読み勝ち
	var counter: bool = not trade and defender.state == FighterCore.State.ATTACK
	attacker.has_hit = true
	defender.take_hit(dmg, knockdown)
	_knock_back(attacker, defender, Moves.KNOCKBACK_DOWN if knockdown else Moves.KNOCKBACK_HIT)
	return {
		"type": "hit",
		"target": target,
		"damage": dmg,
		"hit_count": hit_count,
		"kind": data.name,
		"hitstop": data.hitstop,
		"x": defender.x,
		"trade": trade,
		"counter": counter,
	}


## 被弾側を攻撃側から遠ざける。壁で押せない分は攻撃側が下がる（画面端の連打を切るため）。
func _knock_back(attacker: FighterCore, defender: FighterCore, distance: float) -> void:
	var dir := 1 if defender.x >= attacker.x else -1
	var target := defender.x + dir * distance
	var clamped := clampf(target, defender.min_x, defender.max_x)
	defender.x = clamped
	var remainder := absf(target - clamped)
	if remainder > 0.0:
		attacker.x = clampf(attacker.x - dir * remainder, attacker.min_x, attacker.max_x)


func _check_end() -> Array:
	if p1.hp == 0 or p2.hp == 0:
		finished = true
		if p1.hp == 0 and p2.hp == 0:
			winner = 0
		else:
			winner = 1 if p2.hp == 0 else 2
		return [{"type": "ko", "winner": winner}]
	if time_left_frames <= 0:
		finished = true
		if p1.hp == p2.hp:
			winner = 0
		else:
			winner = 1 if p1.hp > p2.hp else 2
		return [{"type": "time_up", "winner": winner}]
	return []
