class_name InputReader
## キーボードを 1P の入力辞書に変換する。Input を読むのはここだけ。

static func read_p1() -> Dictionary:
	return {
		"left": Input.is_action_pressed("p1_left"),
		"right": Input.is_action_pressed("p1_right"),
		"down": Input.is_action_pressed("p1_down"),
		"high": Input.is_action_pressed("p1_high"),
		"low": Input.is_action_pressed("p1_low"),
		"throw": Input.is_action_pressed("p1_throw"),
	}
