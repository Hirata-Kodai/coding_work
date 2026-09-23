extends GutTest

var runs: Array


func before_all() -> void:
	runs = PvScript.simulate()


func events_of(name: String) -> Array:
	for r in runs:
		if r.name == name:
			return r.events
	fail_test("no segment " + name)
	return []


func state_of(name: String) -> Dictionary:
	for r in runs:
		if r.name == name:
			return r
	fail_test("no segment " + name)
	return {}


func hits_of(name: String) -> Array:
	return events_of(name).filter(func(e): return e.type == "hit")


func test_total_length_is_20_seconds() -> void:
	assert_eq(PvScript.total_frames(), PvScript.TOTAL_FRAMES)


func test_every_segment_has_whole_number_slow() -> void:
	for seg in PvScript.SEGMENTS:
		assert_gt(PvScript.segment_frames(seg), 0, seg.name)
		if seg.steps > 0:
			assert_gte(seg.slow, 1, seg.name)


func test_press_lands_only_on_its_frame() -> void:
	var seg: Dictionary = PvScript.SEGMENTS[0]
	assert_true(PvScript.input_at(seg, 10, 1).high)
	assert_false(PvScript.input_at(seg, 11, 1).high)
	assert_false(PvScript.input_at(seg, 10, 2).high)


func test_hold_spans_its_range() -> void:
	var seg: Dictionary
	for s in PvScript.SEGMENTS:
		if s.name == "rush":
			seg = s
	assert_true(PvScript.input_at(seg, 10, 1).right)
	assert_false(PvScript.input_at(seg, 30, 1).right)


# --- キャプションどおりの出来事が実際に起きること ---

func test_controls_segment_shows_moves_without_hitting() -> void:
	assert_eq(hits_of("controls").size(), 0, "遠いので当たらない")


func test_low_beats_high() -> void:
	var h := hits_of("yomiai_low")
	assert_eq(h.size(), 1)
	assert_eq(h[0].target, 2)
	assert_eq(h[0].kind, "low")
	assert_true(h[0].counter)


func test_throw_beats_low() -> void:
	var h := hits_of("yomiai_throw")
	assert_eq(h.size(), 1)
	assert_eq(h[0].target, 2)
	assert_eq(h[0].kind, "throw")
	assert_true(h[0].counter)


func test_high_beats_throw() -> void:
	var h := hits_of("yomiai_high")
	assert_eq(h.size(), 1)
	assert_eq(h[0].target, 2)
	assert_eq(h[0].kind, "high")
	assert_true(h[0].counter)


# --- ここから決着までが一本の流れ ---

func test_combo_opens_with_a_counter_then_a_second_hit() -> void:
	var h := hits_of("combo")
	assert_eq(h.size(), 2)
	assert_true(h[0].counter, "1発目は相手の技に勝って当てる")
	assert_eq(h[1].hit_count, 2, "2発目は被弾硬直中に入る")
	assert_gt(h[1].damage, h[0].damage, "連続ヒット補正でダメージが上がる")


func test_rush_lands_three_counters_in_a_row() -> void:
	var h := hits_of("rush")
	assert_eq(h.size(), 3)
	for e in h:
		assert_eq(e.target, 2)
		assert_true(e.counter, "すべて読み勝ちのカウンター")


func test_flow_is_continuous_without_resetting_after_the_approach() -> void:
	# combo で位置と体力を置いたあとは、決着まで一度も置き直さない
	for seg in PvScript.SEGMENTS:
		if seg.name in ["rush", "finish"]:
			assert_false(seg.has("setup"), seg.name)


func test_opponent_is_pushed_back_through_the_flow() -> void:
	var after_combo := state_of("combo")
	var after_rush := state_of("rush")
	var after_finish := state_of("finish")
	assert_gt(after_rush.p2_x, after_combo.p2_x, "rush で相手が後ろへ下がる")
	assert_gt(after_finish.p2_x, after_rush.p2_x, "決着でさらに下がる")
	assert_gt(after_rush.p1_x, after_combo.p1_x, "自分は前へ出続ける")


func test_opponent_turns_red_before_the_finisher() -> void:
	# 逆転補正の赤い光が点いた状態で決め技に入る
	assert_lte(state_of("rush").p2_hp, CombatRules.COMEBACK_HP)
	assert_gt(state_of("rush").p2_hp, 0, "rush の途中では倒し切らない")


func test_finisher_is_a_counter_throw_that_ends_the_match() -> void:
	var h := hits_of("finish")
	assert_eq(h.size(), 1)
	assert_eq(h[0].kind, "throw")
	assert_true(h[0].counter)
	var kos := events_of("finish").filter(func(e): return e.type == "ko")
	assert_eq(kos.size(), 1)
	assert_eq(kos[0].winner, 1)
