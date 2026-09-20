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


func test_idle_pose_has_no_limb() -> void:
	var pose := FighterPose.compute(f)
	assert_false(pose.limb.visible)
	assert_almost_eq(pose.body_h, FighterPose.BODY_H, 0.001)
	assert_almost_eq(pose.lean_x, 0.0, 0.001)


func test_crouch_and_down_change_body_shape() -> void:
	f.step(press("down"))
	assert_lt(FighterPose.compute(f).body_h, FighterPose.BODY_H)
	f.take_hit(10, true)
	var pose := FighterPose.compute(f)
	assert_lt(pose.body_h, FighterPose.CROUCH_H)
	assert_gt(pose.body_w, FighterPose.BODY_W)


func test_limb_extends_through_startup_and_is_full_during_active() -> void:
	f.step(press("high"))
	var reach: float = Moves.DATA[Moves.Kind.HIGH].reach
	var first := FighterPose.compute(f)
	assert_true(first.limb.visible)
	assert_lt(first.limb.length, reach)
	var d: Dictionary = Moves.DATA[Moves.Kind.HIGH]
	for _i in d.startup - 1:
		f.step(idle())
	var last_startup := FighterPose.compute(f)
	assert_gt(last_startup.limb.length, first.limb.length)
	f.step(idle())
	var active := FighterPose.compute(f)
	assert_almost_eq(active.limb.length, reach, 0.001)


func test_limb_retracts_during_recovery() -> void:
	f.step(press("low"))
	var d: Dictionary = Moves.DATA[Moves.Kind.LOW]
	for _i in d.startup + d.active:
		f.step(idle())
	var early := FighterPose.compute(f)
	assert_eq(f.attack_phase(), "recovery")
	for _i in d.recovery - 1:
		f.step(idle())
	var late := FighterPose.compute(f)
	assert_lt(late.limb.length, early.limb.length)


func test_startup_leans_back_and_active_leans_forward() -> void:
	f.step(press("high"))
	assert_lt(FighterPose.compute(f).lean_x, 0.0)  # 右向きなので後ろは負
	var d: Dictionary = Moves.DATA[Moves.Kind.HIGH]
	for _i in d.startup:
		f.step(idle())
	assert_gt(FighterPose.compute(f).lean_x, 0.0)


func test_lean_follows_facing() -> void:
	var g := FighterCore.new(400.0, -1)
	g.step(press("high"))
	assert_gt(FighterPose.compute(g).lean_x, 0.0)  # 左向きの後ろは正


func test_limb_height_matches_move_kind() -> void:
	f.step(press("high"))
	var high_y: float = FighterPose.compute(f).limb.y
	var g := FighterCore.new(100.0, 1)
	g.step(press("low"))
	var low_y: float = FighterPose.compute(g).limb.y
	assert_lt(high_y, low_y)  # 上段の方が上（y が小さい）


func test_low_kick_lowers_the_body() -> void:
	f.step(press("low"))
	assert_lt(FighterPose.compute(f).body_h, FighterPose.BODY_H)


func test_hitstun_tilts_backward() -> void:
	f.take_hit(10, false)
	assert_lt(FighterPose.compute(f).tilt, 0.0)
	var g := FighterCore.new(400.0, -1)
	g.take_hit(10, false)
	assert_gt(FighterPose.compute(g).tilt, 0.0)


func test_phase_is_exposed_for_coloring() -> void:
	f.step(press("throw"))
	assert_eq(FighterPose.compute(f).phase, "startup")
