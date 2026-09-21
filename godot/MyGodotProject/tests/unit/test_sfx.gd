extends GutTest

var sfx: Sfx


func before_each() -> void:
	sfx = Sfx.new()
	add_child_autofree(sfx)


func test_each_kind_has_a_stream() -> void:
	for kind in ["high", "low", "throw", "win", "counter"]:
		assert_not_null(sfx.player_for(kind).stream, kind)


func test_pitch_is_base_times_combo_curve() -> void:
	sfx.play_hit("high", 1)
	assert_almost_eq(sfx.player_for("high").pitch_scale, Sfx.BASE_PITCH, 0.001)
	sfx.play_hit("high", 3)
	assert_almost_eq(sfx.player_for("high").pitch_scale, Sfx.BASE_PITCH * 1.16, 0.001)
	sfx.play_hit("low", 9)
	assert_almost_eq(sfx.player_for("low").pitch_scale, Sfx.BASE_PITCH * 1.4, 0.001)


func test_base_pitch_is_raised_above_original() -> void:
	assert_gt(Sfx.BASE_PITCH, 1.0)


func test_win_sound_uses_normal_pitch() -> void:
	sfx.play_win()
	assert_almost_eq(sfx.player_for("win").pitch_scale, 1.0, 0.001)


func test_unknown_kind_is_ignored() -> void:
	sfx.play_hit("nope", 1)
	pass_test("no error")


func test_counter_hit_layers_counter_sound() -> void:
	sfx.play_hit("low", 1, true)
	assert_true(sfx.player_for("counter").playing)
	assert_true(sfx.player_for("low").playing)


func test_plain_hit_does_not_play_counter_sound() -> void:
	sfx.play_hit("low", 1, false)
	assert_false(sfx.player_for("counter").playing)
