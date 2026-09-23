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
		"name": "combo",
		"steps": 15, "slow": 2, "zoom": 1.6,
		# 読み合い区間で減った体力を戻す。KO すると試合が止まって絵が固まるため
		"setup": {"gap": TOUCH_GAP, "p1_hp": Moves.MAX_HP, "p2_hp": Moves.MAX_HP},
		"presses": [[0, 1, "high"]],
		"captions": [[0, "当たれば 止まる・揺れる・光る"]],
	},
	{
		# 2発目は被弾硬直中に入るので連続ヒット補正が乗る。スローで見せる
		"name": "combo_slow",
		"steps": 25, "slow": 3, "zoom": 1.6,
		"presses": [[0, 1, "high"]],
		"captions": [[50, "連続ヒットで 爽快感 UP ！"]],
	},
	{
		# キャプションを出している間を止め絵にしないため、踏み込んでもう一発
		"name": "combo_tail",
		"steps": 30, "slow": 2, "zoom": 1.6,
		"holds": [[0, 10, 1, "right"]],
		"presses": [[12, 1, "high"]],
		"captions": [],
	},
	{
		"name": "speed",
		"steps": 180, "slow": 1, "zoom": 1.15,
		"setup": {"gap": 200.0, "p1_hp": 150, "p2_hp": 150},
		"holds": [[0, 40, 1, "right"], [64, 72, 1, "right"], [87, 95, 1, "right"]],
		"presses": [[41, 1, "low"], [41, 2, "high"], [73, 1, "high"], [73, 2, "throw"], [96, 1, "throw"], [96, 2, "low"]],
		"captions": [[0, "コマンド入力なし  コンボなし"], [110, "読み勝てば 一方的に押し込める"]],
	},
	{
		"name": "ko",
		"steps": 30, "slow": 4, "zoom": 2.0,
		"setup": {"gap": 80.0, "p2_hp": 20},
		"presses": [[5, 1, "low"], [5, 2, "high"]],
		"captions": [],
	},
	{
		"name": "outro",
		"steps": 0, "frames": 210, "slow": 1, "zoom": 2.0,
		"captions": [[15, "K.O."], [75, "3  WIN  STREAK"], [145, "負けても3秒で次が始まる"]],
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
		result.append({"name": seg.name, "events": events})
	return result
