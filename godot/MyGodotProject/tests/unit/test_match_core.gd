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


## 両者を密着させる（p1 を右へ歩かせる）
func close_in() -> void:
	for _i in 600:
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
