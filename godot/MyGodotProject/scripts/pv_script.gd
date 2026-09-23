class_name PvScript
## 20 秒 PV の台本。MatchCore は固定タイムステップで決定論的なので、
## 「何フレーム目に誰が何を押すか」を書けば毎回まったく同じ試合が再生される。
## 見せ場は slow（試合1フレームを映像何フレームで見せるか）で引き伸ばす。

const FPS := 60
const TOTAL_FRAMES := 20 * FPS
const STAGE_WIDTH := 1152.0
const TOUCH_GAP := Moves.BODY_HALF_WIDTH * 2  # 密着時の中心間距離

## steps: 進める試合フレーム数 / slow: 1試合フレームあたりの映像フレーム数
## frames: 試合を進めない演出専用区間の長さ
## setup: 区間の頭で両者をこの状態に置く
## presses: [[local_step, player, key], ...] そのフレームだけ押す
## holds: [[from_step, to_step, player, key], ...]
## captions: [[local_frame, text], ...] 次のキャプションか区間終了まで出し続ける
const SEGMENTS := [
	{
		"name": "controls",
		"steps": 120, "slow": 1, "zoom": 1.15,
		"setup": {"gap": 400.0},
		"presses": [[10, 1, "high"], [50, 1, "low"], [85, 1, "throw"]],
		"captions": [[0, "ボタンは3つ"], [10, "[Z]  上段"], [50, "[X]  下段"], [85, "[C]  投げ"]],
	},
	{
		"name": "yomiai_low",
		"steps": 45, "slow": 3, "zoom": 1.7,
		"setup": {"gap": 80.0},
		"presses": [[5, 1, "low"], [5, 2, "high"]],
		"captions": [[0, "読み合いは3すくみだけ"], [45, "下段  ＞  上段"]],
	},
	{
		"name": "yomiai_throw",
		"steps": 50, "slow": 3, "zoom": 1.7,
		"setup": {"gap": 70.0},
		"presses": [[5, 1, "throw"], [5, 2, "low"]],
		"captions": [[60, "投げ  ＞  下段"]],
	},
	{
		"name": "yomiai_high",
		"steps": 40, "slow": 3, "zoom": 1.7,
		"setup": {"gap": 80.0},
		"presses": [[5, 1, "high"], [5, 2, "throw"]],
		"captions": [[40, "上段  ＞  投げ"]],
	},
	{
		# ここから決着まで一本の流れ。踏み込んで初カウンター → 連続ヒット →
		# カウンターを重ねて押し込む → 投げで決着、と続ける（途中で切らない）
		"name": "combo",
		"steps": 75, "slow": 1, "zoom": 1.4,
		"setup": {"gap": 200.0, "p1_hp": Moves.MAX_HP, "p2_hp": Moves.MAX_HP},
		"holds": [[0, 44, 1, "right"]],
		"presses": [[44, 1, "high"], [44, 2, "throw"], [58, 1, "high"]],
		"captions": [[20, "当たれば 止まる・揺れる・光る"], [60, "連続ヒットで 爽快感 UP ！"]],
	},
	{
		# 相手が技を振るたびに勝つ手を合わせる。ノックバックで相手が右へ下がり、
		# 踏み込んで距離を詰め直すので、画面ごと押し込んでいく絵になる
		"name": "rush",
		"steps": 92, "slow": 2, "zoom": 1.5,
		"holds": [[0, 13, 1, "right"], [36, 45, 1, "right"], [59, 68, 1, "right"]],
		"presses": [
			[14, 1, "low"], [14, 2, "high"],
			[46, 1, "high"], [46, 2, "throw"],
			[69, 1, "high"], [69, 2, "throw"],
		],
		"captions": [[60, "読み勝てば 一方的に押し込める"]],
	},
	{
		"name": "finish",
		"steps": 30, "slow": 4, "zoom": 2.0,
		"holds": [[0, 9, 1, "right"]],
		"presses": [[10, 1, "throw"], [10, 2, "low"]],
		"captions": [],
	},
	{
		"name": "outro",
		"steps": 0, "frames": 296, "slow": 1, "zoom": 2.0,
		"captions": [[15, "K.O."], [85, "3  WIN  STREAK"], [160, "コマンド入力なし  コンボなし"], [235, "負けても3秒で次が始まる"]],
	},
]


static func segment_frames(seg: Dictionary) -> int:
	if seg.steps == 0:
		return seg.get("frames", 0)
	return seg.steps * seg.slow


static func total_frames() -> int:
	var total := 0
	for seg in SEGMENTS:
		total += segment_frames(seg)
	return total


## この区間の local_step における player(1/2) の入力辞書。
static func input_at(seg: Dictionary, local_step: int, player: int) -> Dictionary:
	var input := FighterCore.empty_input()
	for h in seg.get("holds", []):
		if h[2] == player and local_step >= h[0] and local_step < h[1]:
			input[h[3]] = true
	for p in seg.get("presses", []):
		if p[1] == player and p[0] == local_step:
			input[p[2]] = true
	return input


## 区間の頭で両者を配置し直す。PV は試合の流れではなく見せ場の並びなので、
## 台本側から位置と体力を直接置く。
static func apply_setup(m: MatchCore, setup: Dictionary) -> void:
	var gap: float = setup.get("gap", 0.0)
	if gap > 0.0:
		var center := STAGE_WIDTH / 2.0
		m.p1.x = center - gap / 2.0
		m.p2.x = center + gap / 2.0
	for pair in [[m.p1, "p1_hp"], [m.p2, "p2_hp"]]:
		var f: FighterCore = pair[0]
		if setup.has(pair[1]):
			f.hp = setup[pair[1]]
		f.state = FighterCore.State.IDLE
		f.frame = 0
		f.combo_count = 0
		f.invuln_frames = 0
		f.has_hit = false
		f._prev_input = FighterCore.empty_input()
	m.finished = false
	m.winner = 0


## 台本を最後まで回し、区間ごとのイベントを返す（テストと事前確認用）。
static func simulate() -> Array:
	var m := MatchCore.new(STAGE_WIDTH)
	m.time_left_frames = Moves.ROUND_FRAMES
	var result := []
	for seg in SEGMENTS:
		if seg.has("setup"):
			apply_setup(m, seg.setup)
		var events := []
		for step in seg.steps:
			events.append_array(m.step(input_at(seg, step, 1), input_at(seg, step, 2)))
		result.append({
			"name": seg.name, "events": events,
			"p1_x": m.p1.x, "p2_x": m.p2.x, "p1_hp": m.p1.hp, "p2_hp": m.p2.hp,
		})
	return result
