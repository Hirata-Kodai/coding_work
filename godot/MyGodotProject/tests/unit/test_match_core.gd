extends GutTest

var m: MatchCore


func before_each() -> void:
	m = MatchCore.new(1152.0)


func idle() -> Dictionary:
	return FighterCore.empty_input()


func press(key: String) -> Dictionary:
	var i := idle()
	i[key] = true
	return i


## 両者を密着させる（p1 を右へ歩かせ、触れたら止める）
func close_in() -> void:
	while m.p2.x - m.p1.x > Moves.BODY_HALF_WIDTH * 2 + 0.001:
		m.step(press("right"), idle())
	m.step(idle(), idle())


func run(in1: Dictionary, in2: Dictionary, n: int) -> Array:
	var events := []
	for _i in n:
		events.append_array(m.step(in1, in2))
	return events


func hits(events: Array) -> Array:
	return events.filter(func(e): return e.type == "hit")


# --- 初期配置と観測 ---

func test_initial_positions_face_each_other() -> void:
	assert_lt(m.p1.x, m.p2.x)
	assert_eq(m.p1.facing, 1)
	assert_eq(m.p2.facing, -1)


func test_get_state_matches_spec_format() -> void:
	var s := m.get_state()
	assert_eq(s.keys(), ["tick", "p1", "p2", "time_left"])
	assert_eq(s.tick, 0)
	assert_almost_eq(s.time_left, 30.0, 0.001)
	assert_eq(s.p1.keys(), ["x", "hp", "state"])


func test_time_left_counts_down_in_seconds() -> void:
	run(idle(), idle(), 60)
	assert_almost_eq(m.get_state().time_left, 29.0, 0.001)


# --- 間合い ---

func test_attack_whiffs_at_long_range() -> void:
	var events := run(press("high"), idle(), 20)
	assert_eq(hits(events).size(), 0)
	assert_eq(m.p2.hp, Moves.MAX_HP)


func test_bodies_do_not_overlap() -> void:
	close_in()
	assert_almost_eq(m.p2.x - m.p1.x, Moves.BODY_HALF_WIDTH * 2, 0.001)


# --- ヒット ---

func test_high_hits_at_close_range() -> void:
	close_in()
	var events := run(press("high"), idle(), 20)
	var h := hits(events)
	assert_eq(h.size(), 1)
	assert_eq(h[0].target, 2)
	assert_eq(h[0].damage, 25)
	assert_eq(h[0].hit_count, 1)
	assert_eq(h[0].hitstop, 8)
	assert_eq(m.p2.hp, 125)
	assert_eq(m.p2.state, FighterCore.State.HITSTUN)


func test_crouch_avoids_high_but_not_low() -> void:
	close_in()
	run(press("high"), press("down"), 20)
	assert_eq(m.p2.hp, Moves.MAX_HP)
	run(press("low"), press("down"), 30)
	assert_eq(m.p2.hp, Moves.MAX_HP - 30)


func test_throw_knocks_down() -> void:
	close_in()
	var events := run(press("throw"), idle(), 40)
	assert_eq(hits(events).size(), 1)
	assert_eq(m.p2.state, FighterCore.State.DOWN)
	assert_eq(m.p2.hp, 105)


func test_throw_cannot_grab_downed_opponent() -> void:
	close_in()
	run(press("throw"), idle(), Moves.total_frames(Moves.Kind.THROW))  # p1 硬直明け、p2 はまだダウン中
	m.step(idle(), idle())
	var d: Dictionary = Moves.DATA[Moves.Kind.THROW]
	var events := run(press("throw"), idle(), d.startup + d.active)  # 持続フレームが終わるまで
	assert_eq(m.p2.state, FighterCore.State.DOWN)  # 投げが届く時点でまだダウン中
	assert_eq(hits(events).size(), 0)


# --- 3すくみ ---

func test_low_beats_high_when_pressed_together() -> void:
	close_in()
	run(press("high"), press("low"), 30)
	assert_eq(m.p2.hp, Moves.MAX_HP)  # 上段は空振り
	assert_eq(m.p1.hp, Moves.MAX_HP - 30)


func test_high_beats_throw() -> void:
	close_in()
	run(press("throw"), press("high"), 30)
	assert_eq(m.p1.hp, Moves.MAX_HP - 25)
	assert_eq(m.p2.hp, Moves.MAX_HP)


func test_throw_beats_low() -> void:
	close_in()
	run(press("low"), press("throw"), 40)
	assert_eq(m.p2.hp, Moves.MAX_HP)
	assert_eq(m.p1.hp, Moves.MAX_HP - 45)
	assert_eq(m.p1.state, FighterCore.State.DOWN)


func test_same_move_trades_and_both_go_down() -> void:
	close_in()
	var events := run(press("high"), press("high"), 20)
	assert_eq(hits(events).size(), 2)
	assert_eq(m.p1.hp, Moves.MAX_HP - 25)
	assert_eq(m.p2.hp, Moves.MAX_HP - 25)
	assert_eq(m.p1.state, FighterCore.State.DOWN)
	assert_eq(m.p2.state, FighterCore.State.DOWN)


# --- 連続ヒット補正 ---

func test_second_hit_during_hitstun_is_scaled() -> void:
	close_in()
	run(press("high"), idle(), Moves.total_frames(Moves.Kind.HIGH))
	m.step(idle(), idle())
	var events := run(press("high"), idle(), 10)
	var h := hits(events)
	assert_eq(h.size(), 1)
	assert_eq(h[0].hit_count, 2)
	assert_eq(h[0].damage, 30)


# --- 決着 ---

func test_ko_ends_match() -> void:
	close_in()
	m.p2.hp = 25
	var events := run(press("high"), idle(), 20)
	var kos := events.filter(func(e): return e.type == "ko")
	assert_eq(kos.size(), 1)
	assert_eq(kos[0].winner, 1)
	assert_true(m.finished)
	assert_eq(m.winner, 1)
	assert_eq(m.step(press("high"), idle()), [])


func test_time_up_higher_hp_wins() -> void:
	m.p2.hp = 100
	var events := run(idle(), idle(), Moves.ROUND_FRAMES)
	var ups := events.filter(func(e): return e.type == "time_up")
	assert_eq(ups.size(), 1)
	assert_eq(ups[0].winner, 1)
	assert_true(m.finished)


func test_time_up_equal_hp_is_draw() -> void:
	var events := run(idle(), idle(), Moves.ROUND_FRAMES)
	var ups := events.filter(func(e): return e.type == "time_up")
	assert_eq(ups[0].winner, 0)
	assert_eq(m.winner, 0)


# --- ノックバック ---

func test_hit_pushes_defender_back() -> void:
	close_in()
	var before := m.p2.x
	run(press("high"), idle(), 10)
	assert_almost_eq(m.p2.x - before, Moves.KNOCKBACK_HIT, 0.001)


func test_knockdown_pushes_further() -> void:
	close_in()
	var before := m.p2.x
	run(press("throw"), idle(), 20)
	assert_almost_eq(m.p2.x - before, Moves.KNOCKBACK_DOWN, 0.001)


func test_cornered_defender_pushes_attacker_back_instead() -> void:
	# p2 を右端まで追い込む
	for _i in 1200:
		m.step(press("right"), idle())
	m.step(idle(), idle())
	assert_almost_eq(m.p2.x, m.p2.max_x, 0.001)
	var p1_before := m.p1.x
	run(press("high"), idle(), 10)
	assert_almost_eq(m.p2.x, m.p2.max_x, 0.001)
	assert_almost_eq(p1_before - m.p1.x, Moves.KNOCKBACK_HIT, 0.001)


func test_high_spam_does_not_loop_forever() -> void:
	close_in()
	var events := []
	for _i in 120:
		var i := press("high")
		i.right = true
		events.append_array(m.step(i, idle()))
	var h := hits(events)
	assert_gt(h.size(), 0)
	# ノックバックで間合いが切れるので、2発目以降が全部繋がることはない
	var max_combo: int = h.map(func(e): return e.hit_count).max()
	assert_lt(max_combo, 4)


# --- 起き上がり ---

func test_attack_whiffs_on_wakeup() -> void:
	close_in()
	run(press("throw"), idle(), Moves.total_frames(Moves.Kind.THROW))
	# p2 が起きるまで p1 は歩いて追いかける
	while m.p2.state == FighterCore.State.DOWN:
		m.step(press("right"), idle())
	assert_true(m.p2.is_invulnerable())
	var events := run(press("high"), idle(), 10)
	assert_eq(hits(events).size(), 0)


# --- 攻撃中の前傾で差し返しが当たる ---

func test_whiffed_throw_can_be_punished_from_slightly_further() -> void:
	# 上段が届かないぎりぎりの距離に p2 を置く（食らい判定の前端までの距離 = reach + 少し）
	var reach: float = Moves.DATA[Moves.Kind.HIGH].reach
	var lean: float = Moves.DATA[Moves.Kind.THROW].lean
	m.p1.x = 400.0
	m.p2.x = 400.0 + Moves.BODY_HALF_WIDTH * 2 + reach + lean * 0.5
	# 待機中の p2 には届かない
	var whiff := run(press("high"), idle(), 20)
	assert_eq(hits(whiff).size(), 0)
	# p2 が投げを空振りして前傾している間なら届く
	m.step(idle(), press("throw"))
	var d: Dictionary = Moves.DATA[Moves.Kind.THROW]
	run(idle(), idle(), d.startup)  # 持続に入る
	assert_eq(m.p2.attack_phase(), "active")
	var punish := run(press("high"), idle(), 10)
	assert_eq(hits(punish).size(), 1)
	assert_eq(hits(punish)[0].target, 2)


# --- 3すくみに勝った当たりは counter ---

func test_plain_hit_is_not_counter() -> void:
	close_in()
	var h := hits(run(press("high"), idle(), 20))
	assert_eq(h.size(), 1)
	assert_false(h[0].counter)


func test_hit_that_beats_opponents_move_is_counter() -> void:
	close_in()
	# p1 上段 vs p2 下段 → 下段が勝って p1 に当たる
	var h := hits(run(press("high"), press("low"), 30))
	assert_eq(h.size(), 1)
	assert_eq(h[0].target, 1)
	assert_true(h[0].counter)


func test_hit_during_opponents_recovery_is_counter() -> void:
	# 空振りした技の硬直中に当てるのも「読み勝ち」として扱う
	# 投げ(reach 40)は届かず、上段(reach 46 + 前傾 18)は届く距離に置く
	m.p1.x = 400.0
	m.p2.x = 400.0 + Moves.BODY_HALF_WIDTH * 2 + 50.0
	m.step(idle(), press("throw"))
	var d: Dictionary = Moves.DATA[Moves.Kind.THROW]
	run(idle(), idle(), d.startup + d.active)
	assert_eq(m.p2.attack_phase(), "recovery")
	var h := hits(run(press("high"), idle(), 10))
	assert_eq(h.size(), 1)
	assert_true(h[0].counter)
