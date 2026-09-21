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


func test_every_clip_has_a_file_and_valid_range() -> void:
	for name in FighterAnim.CLIPS:
		var c: Dictionary = FighterAnim.CLIPS[name]
		assert_true(FileAccess.file_exists(c.file), c.file)
		assert_lt(c.start, c.end, name)


func test_idle_loops_from_frame_counter() -> void:
	var a := FighterAnim.select(f)
	assert_eq(a.clip, "idle")
	assert_almost_eq(a.time, FighterAnim.CLIPS.idle.start, 0.001)
	step_n(30, idle())
	assert_almost_eq(FighterAnim.select(f).time, FighterAnim.CLIPS.idle.start + 0.5, 0.001)


func test_loop_wraps_within_clip_range() -> void:
	var c: Dictionary = FighterAnim.CLIPS.idle
	var frames := int((c.end - c.start) * 60) + 10
	step_n(frames, idle())
	var t: float = FighterAnim.select(f).time
	assert_between(t, c.start, c.end)


func test_walk_and_crouch_select_their_clips() -> void:
	f.step(press("right"))
	assert_eq(FighterAnim.select(f).clip, "walk")
	f.step(press("down"))
	assert_eq(FighterAnim.select(f).clip, "crouch")


func test_attack_maps_whole_move_onto_trimmed_clip() -> void:
	f.step(press("high"))
	var c: Dictionary = FighterAnim.CLIPS.high
	assert_almost_eq(FighterAnim.select(f).time, c.start, 0.001)
	step_n(Moves.total_frames(Moves.Kind.HIGH) - 1, idle())
	assert_eq(FighterAnim.select(f).clip, "high")
	assert_almost_eq(FighterAnim.select(f).time, c.end, 0.001)


func test_first_active_frame_shows_impact_pose() -> void:
	for pair in [["high", Moves.Kind.HIGH], ["low", Moves.Kind.LOW], ["throw", Moves.Kind.THROW]]:
		var g := FighterCore.new(100.0, 1)
		g.step(press(pair[0]))
		step_n_on(g, Moves.DATA[pair[1]].startup)
		assert_eq(g.attack_phase(), "active")
		assert_almost_eq(FighterAnim.select(g).time, FighterAnim.CLIPS[pair[0]].impact, 0.001, pair[0])


func step_n_on(g: FighterCore, n: int) -> void:
	for _i in n:
		g.step(idle())


func test_attack_clips_have_impact_between_start_and_end() -> void:
	for name in ["high", "low", "throw"]:
		var c: Dictionary = FighterAnim.CLIPS[name]
		assert_between(c.impact, c.start, c.end, name)


func test_each_move_has_its_own_clip() -> void:
	var g := FighterCore.new(100.0, 1)
	g.step(press("low"))
	assert_eq(FighterAnim.select(g).clip, "low")
	var h := FighterCore.new(100.0, 1)
	h.step(press("throw"))
	assert_eq(FighterAnim.select(h).clip, "throw")


func test_hitstun_and_down_split_into_fall_and_getup() -> void:
	f.take_hit(10, false)
	assert_eq(FighterAnim.select(f).clip, "hit")
	f.take_hit(10, true)
	assert_eq(FighterAnim.select(f).clip, "down")
	step_n(Moves.DOWN_FRAMES / 2, idle())
	assert_eq(FighterAnim.select(f).clip, "getup")
	step_n(Moves.DOWN_FRAMES / 2, idle())
	assert_eq(FighterAnim.select(f).clip, "idle")


func test_time_never_leaves_clip_range() -> void:
	var seq := ["high", "low", "throw", "right", "down"]
	for key in seq:
		f.step(press(key))
		for _i in 40:
			var a := FighterAnim.select(f)
			var c: Dictionary = FighterAnim.CLIPS[a.clip]
			assert_between(a.time, c.start - 0.0001, c.end + 0.0001, a.clip)
			f.step(idle())
