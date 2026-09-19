extends GutTest

var me: FighterCore
var opp: FighterCore


func before_each() -> void:
	me = FighterCore.new(600.0, -1)
	opp = FighterCore.new(500.0, 1)


func brain(level: int, seed_value: int = 1) -> CpuBrain:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	return CpuBrain.new(level, rng)


func attack_kinds(b: CpuBrain, n: int) -> Dictionary:
	# n 回意思決定し、押された攻撃ボタンを数える
	var counts := {"high": 0, "low": 0, "throw": 0, "none": 0}
	for _i in n:
		b.reset()
		var input := b.decide(me, opp)
		var pressed := "none"
		for k in ["high", "low", "throw"]:
			if input[k]:
				pressed = k
		counts[pressed] += 1
	return counts


func test_counter_move_beats_given_move() -> void:
	assert_eq(CpuBrain.counter_move(Moves.Kind.HIGH), Moves.Kind.LOW)
	assert_eq(CpuBrain.counter_move(Moves.Kind.LOW), Moves.Kind.THROW)
	assert_eq(CpuBrain.counter_move(Moves.Kind.THROW), Moves.Kind.HIGH)


func test_output_has_input_dictionary_shape() -> void:
	var input := brain(1).decide(me, opp)
	assert_eq(input.keys(), FighterCore.empty_input().keys())


func test_level1_uses_all_three_moves() -> void:
	var counts := attack_kinds(brain(1), 300)
	for k in ["high", "low", "throw"]:
		assert_gt(counts[k], 30, k + " should be used")


func test_level2_does_not_attack_out_of_range() -> void:
	opp.x = 100.0  # 遠い
	var counts := attack_kinds(brain(2), 100)
	assert_eq(counts.high + counts.low + counts.throw, 0)


func test_level2_walks_toward_opponent_when_far() -> void:
	opp.x = 100.0
	var input := brain(2).decide(me, opp)
	assert_true(input.left)
	assert_false(input.right)


func test_level5_counters_opponent_attack_almost_always() -> void:
	opp.step(_press("low"))  # 相手が下段を出し始めた
	var counts := attack_kinds(brain(5), 100)
	assert_gt(counts.throw, 90)


func test_level3_counters_about_half_the_time() -> void:
	opp.step(_press("high"))
	var counts := attack_kinds(brain(3), 400)
	assert_between(counts.low, 140, 300)


func test_level1_ignores_opponent_attack() -> void:
	opp.step(_press("high"))
	var counts := attack_kinds(brain(1), 300)
	assert_lt(counts.low, 200)


func test_decision_is_held_for_several_frames() -> void:
	var b := brain(2)
	var first := b.decide(me, opp)
	var second := b.decide(me, opp)
	# 攻撃ボタンは押した最初の1フレームだけ true（押しっぱなし防止）
	if first.high or first.low or first.throw:
		assert_false(second.high or second.low or second.throw)
	else:
		assert_eq(first.left, second.left)


func _press(key: String) -> Dictionary:
	var i := FighterCore.empty_input()
	i[key] = true
	return i
