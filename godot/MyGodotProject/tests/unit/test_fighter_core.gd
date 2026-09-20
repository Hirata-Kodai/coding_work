extends GutTest

var f: FighterCore


func before_each() -> void:
	f = FighterCore.new(100.0, 1)


func idle() -> Dictionary:
	return FighterCore.empty_input()


func press(key: String) -> Dictionary:
	var i := idle()
	i[key] = true
	return i


func step_n(n: int, input: Dictionary) -> void:
	for _i in n:
		f.step(input)


# --- 初期状態 ---

func test_initial_state() -> void:
	assert_eq(f.hp, Moves.MAX_HP)
	assert_eq(f.state, FighterCore.State.IDLE)
	assert_eq(f.x, 100.0)
	assert_eq(f.facing, 1)


# --- 移動としゃがみ ---

func test_walk_right_moves_forward() -> void:
	f.step(press("right"))
	assert_eq(f.state, FighterCore.State.WALK)
	assert_almost_eq(f.x, 100.0 + Moves.MOVE_SPEED, 0.001)


func test_walk_left_moves_back() -> void:
	f.step(press("left"))
	assert_almost_eq(f.x, 100.0 - Moves.MOVE_SPEED, 0.001)


func test_no_input_returns_to_idle() -> void:
	f.step(press("right"))
	f.step(idle())
	assert_eq(f.state, FighterCore.State.IDLE)


func test_crouch_blocks_movement() -> void:
	var i := press("down")
	i["right"] = true
	f.step(i)
	assert_eq(f.state, FighterCore.State.CROUCH)
	assert_eq(f.x, 100.0)


func test_position_is_clamped_to_bounds() -> void:
	f.min_x = 90.0
	step_n(60, press("left"))
	assert_eq(f.x, 90.0)


# --- 攻撃 ---

func test_high_button_starts_attack() -> void:
	f.step(press("high"))
	assert_eq(f.state, FighterCore.State.ATTACK)
	assert_eq(f.move, Moves.Kind.HIGH)
	assert_eq(f.frame, 0)


func test_attack_is_active_only_during_active_frames() -> void:
	f.step(press("high"))  # frame 0
	var d: Dictionary = Moves.DATA[Moves.Kind.HIGH]
	var active_frames: Array[int] = []
	for i in Moves.total_frames(Moves.Kind.HIGH):
		if f.is_attack_active():
			active_frames.append(f.frame)
		f.step(idle())
	assert_eq(active_frames, range(d.startup, d.startup + d.active))


func test_attack_returns_to_idle_after_total_frames() -> void:
	f.step(press("high"))
	step_n(Moves.total_frames(Moves.Kind.HIGH) - 1, idle())
	assert_eq(f.state, FighterCore.State.ATTACK)
	f.step(idle())
	assert_eq(f.state, FighterCore.State.IDLE)


func test_holding_button_does_not_retrigger() -> void:
	step_n(Moves.total_frames(Moves.Kind.LOW) + 5, press("low"))
	assert_eq(f.state, FighterCore.State.IDLE)


func test_inputs_ignored_during_attack() -> void:
	f.step(press("throw"))
	f.step(press("right"))
	assert_eq(f.state, FighterCore.State.ATTACK)
	assert_eq(f.x, 100.0)


func test_attack_reach_extends_in_facing_direction() -> void:
	f.step(press("high"))
	var reach: float = Moves.DATA[Moves.Kind.HIGH].reach
	assert_almost_eq(f.attack_front_x(), 100.0 + Moves.BODY_HALF_WIDTH + reach, 0.001)
	var g := FighterCore.new(400.0, -1)
	g.step(press("high"))
	assert_almost_eq(g.attack_front_x(), 400.0 - Moves.BODY_HALF_WIDTH - reach, 0.001)


# --- 被弾 ---

func test_take_hit_reduces_hp_and_enters_hitstun() -> void:
	f.take_hit(30, false)
	assert_eq(f.hp, 120)
	assert_eq(f.state, FighterCore.State.HITSTUN)
	assert_eq(f.combo_count, 1)


func test_hitstun_ends_and_resets_combo() -> void:
	f.take_hit(30, false)
	step_n(Moves.HITSTUN_FRAMES, press("right"))
	assert_eq(f.state, FighterCore.State.IDLE)
	assert_eq(f.combo_count, 0)


func test_hit_during_hitstun_increments_combo() -> void:
	f.take_hit(30, false)
	f.step(idle())
	f.take_hit(30, false)
	assert_eq(f.combo_count, 2)
	assert_eq(f.frame, 0)  # 硬直は延長される


func test_knockdown_enters_down_state() -> void:
	f.take_hit(45, true)
	assert_eq(f.state, FighterCore.State.DOWN)
	step_n(Moves.DOWN_FRAMES, idle())
	assert_eq(f.state, FighterCore.State.IDLE)


func test_hp_does_not_go_below_zero() -> void:
	f.take_hit(999, false)
	assert_eq(f.hp, 0)


func test_state_dict_matches_spec_keys() -> void:
	var s := f.get_state_dict()
	assert_eq(s.keys(), ["x", "hp", "state"])
	assert_eq(s.state, "idle")
	f.step(press("low"))
	assert_eq(f.get_state_dict().state, "attack_low")


# --- 技の段階 ---

func test_attack_phase_progression() -> void:
	assert_eq(f.attack_phase(), "")
	f.step(press("high"))  # frame 0: 発生
	var d: Dictionary = Moves.DATA[Moves.Kind.HIGH]
	var phases: Array[String] = []
	for i in Moves.total_frames(Moves.Kind.HIGH):
		phases.append(f.attack_phase())
		f.step(idle())
	assert_eq(phases.count("startup"), d.startup)
	assert_eq(phases.count("active"), d.active)
	assert_eq(phases.count("recovery"), d.recovery)
	assert_eq(phases.slice(0, d.startup), Array(phases.slice(0, d.startup)).filter(func(p): return p == "startup"))


func test_phase_progress_goes_from_zero_to_one() -> void:
	f.step(press("low"))
	assert_almost_eq(f.phase_progress(), 0.0, 0.001)
	var d: Dictionary = Moves.DATA[Moves.Kind.LOW]
	step_n(d.startup - 1, idle())  # 発生の最終フレーム
	assert_almost_eq(f.phase_progress(), 1.0, 0.001)
	f.step(idle())  # 持続の最初
	assert_eq(f.attack_phase(), "active")
	assert_almost_eq(f.phase_progress(), 0.0, 0.001)


# --- 起き上がり無敵 ---

func test_invulnerable_right_after_getting_up() -> void:
	f.take_hit(10, true)
	step_n(Moves.DOWN_FRAMES, idle())
	assert_eq(f.state, FighterCore.State.IDLE)
	assert_true(f.is_invulnerable())
	step_n(Moves.WAKEUP_INVULN_FRAMES - 1, idle())
	assert_true(f.is_invulnerable())
	f.step(idle())
	assert_false(f.is_invulnerable())


func test_not_invulnerable_after_hitstun() -> void:
	f.take_hit(10, false)
	step_n(Moves.HITSTUN_FRAMES, idle())
	assert_false(f.is_invulnerable())


func test_can_act_while_invulnerable() -> void:
	f.take_hit(10, true)
	step_n(Moves.DOWN_FRAMES, idle())
	f.step(press("high"))
	assert_eq(f.state, FighterCore.State.ATTACK)
	assert_true(f.is_invulnerable())
