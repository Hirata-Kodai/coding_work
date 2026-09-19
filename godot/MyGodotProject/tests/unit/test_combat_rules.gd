extends GutTest



# --- 3すくみ: 上段 < 下段 < 投げ < 上段 ---

func test_high_beats_throw() -> void:
	assert_eq(CombatRules.compare(Moves.Kind.HIGH, Moves.Kind.THROW), CombatRules.Outcome.WIN)


func test_low_beats_high() -> void:
	assert_eq(CombatRules.compare(Moves.Kind.LOW, Moves.Kind.HIGH), CombatRules.Outcome.WIN)


func test_throw_beats_low() -> void:
	assert_eq(CombatRules.compare(Moves.Kind.THROW, Moves.Kind.LOW), CombatRules.Outcome.WIN)


func test_reverse_pairs_lose() -> void:
	assert_eq(CombatRules.compare(Moves.Kind.THROW, Moves.Kind.HIGH), CombatRules.Outcome.LOSE)
	assert_eq(CombatRules.compare(Moves.Kind.HIGH, Moves.Kind.LOW), CombatRules.Outcome.LOSE)
	assert_eq(CombatRules.compare(Moves.Kind.LOW, Moves.Kind.THROW), CombatRules.Outcome.LOSE)


func test_same_kind_is_trade() -> void:
	for kind in [Moves.Kind.HIGH, Moves.Kind.LOW, Moves.Kind.THROW]:
		assert_eq(CombatRules.compare(kind, kind), CombatRules.Outcome.TRADE)


# --- しゃがみ回避 ---

func test_crouch_avoids_only_high() -> void:
	assert_true(CombatRules.crouch_avoids(Moves.Kind.HIGH))
	assert_false(CombatRules.crouch_avoids(Moves.Kind.LOW))
	assert_false(CombatRules.crouch_avoids(Moves.Kind.THROW))


# --- ダメージ計算 ---

func test_first_hit_is_base_damage() -> void:
	assert_eq(CombatRules.damage(30, 1, 150), 30)


func test_combo_scaling() -> void:
	assert_eq(CombatRules.damage(30, 2, 150), 36)  # 1.2倍
	assert_eq(CombatRules.damage(30, 3, 150), 42)  # 1.4倍
	assert_eq(CombatRules.damage(30, 4, 150), 45)  # 1.5倍
	assert_eq(CombatRules.damage(30, 9, 150), 45)  # 1.5倍で打ち止め


func test_comeback_bonus_when_attacker_hp_low() -> void:
	assert_eq(CombatRules.damage(30, 1, 40), 45)  # HP40以下で1.5倍
	assert_eq(CombatRules.damage(30, 1, 41), 30)


func test_combo_and_comeback_stack() -> void:
	# 30 * 1.2 * 1.5 = 54
	assert_eq(CombatRules.damage(30, 2, 10), 54)


func test_damage_rounds_down() -> void:
	# 25 * 1.2 = 30.0, 25 * 1.4 = 35.0, 45 * 1.2 = 54.0, 25*1.5*1.4=52.5 -> 52
	assert_eq(CombatRules.damage(25, 3, 40), 52)


# --- 音程（演出用だが同じカウンタで動くのでここに置く） ---

func test_pitch_scale_rises_with_hits_and_caps() -> void:
	assert_almost_eq(CombatRules.pitch_scale(1), 1.0, 0.001)
	assert_almost_eq(CombatRules.pitch_scale(2), 1.08, 0.001)
	assert_almost_eq(CombatRules.pitch_scale(5), 1.32, 0.001)
	assert_almost_eq(CombatRules.pitch_scale(6), 1.4, 0.001)
	assert_almost_eq(CombatRules.pitch_scale(20), 1.4, 0.001)
