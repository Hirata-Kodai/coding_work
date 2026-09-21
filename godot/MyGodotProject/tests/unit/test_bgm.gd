extends GutTest


func test_bgm_starts_and_loops() -> void:
	var bgm := Bgm.new()
	add_child_autofree(bgm)
	assert_true(bgm.started)
	assert_not_null(bgm._player.stream)
	assert_true(bgm.is_looping())
	assert_lt(Bgm.VOLUME_DB, 0.0)
