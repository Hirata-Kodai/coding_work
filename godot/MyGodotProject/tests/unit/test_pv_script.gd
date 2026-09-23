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
		if s.name == "speed":
			seg = s
	assert_true(PvScript.input_at(seg, 10, 1).right)
	assert_false(PvScript.input_at(seg, 40, 1).right)


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


func test_combo_reaches_two_hits() -> void:
	var h := hits_of("combo") + hits_of("combo_slow")
	assert_eq(h.size(), 2)
	assert_eq(h[1].hit_count, 2, "2発目は連続ヒット補正が乗る")
	assert_gt(h[1].damage, h[0].damage)


func test_speed_segment_has_several_exchanges() -> void:
	assert_gte(hits_of("speed").size(), 3)


func test_ko_segment_ends_the_match_with_p1_winning() -> void:
	var kos := events_of("ko").filter(func(e): return e.type == "ko")
	assert_eq(kos.size(), 1)
	assert_eq(kos[0].winner, 1)
