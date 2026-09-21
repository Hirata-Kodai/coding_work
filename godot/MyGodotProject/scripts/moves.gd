class_name Moves
## 技データ。60fps 基準のフレーム数。10日目の調整対象はここに集約する。

enum Kind { HIGH, LOW, THROW }

## 技ごとの数値。startup: 発生、active: 持続、recovery: 硬直、
## damage: 基礎ダメージ、hitstop: ヒット時に両者を止めるフレーム数、
## reach: 攻撃側の胴体の前端からさらに前方に届く距離(px)。
## リーチと胴体幅は 3D モデルの骨の位置を実測して決めた（肩幅 34px、拳の先端は腰から 61px 等）。
const DATA := {
	Kind.HIGH: {
		"name": "high",
		"startup": 4, "active": 3, "recovery": 6,
		"damage": 25, "hitstop": 8, "reach": 46,
	},
	Kind.LOW: {
		"name": "low",
		"startup": 7, "active": 3, "recovery": 12,
		"damage": 30, "hitstop": 8, "reach": 52,
	},
	Kind.THROW: {
		"name": "throw",
		"startup": 12, "active": 2, "recovery": 20,
		"damage": 45, "hitstop": 14, "reach": 40,
	},
}

const MAX_HP := 150
const MOVE_SPEED := 200.0 / 60.0  # px/frame（200px/秒）
const ROUND_FRAMES := 30 * 60
const HITSTUN_FRAMES := 18
const DOWN_FRAMES := 40
const WAKEUP_INVULN_FRAMES := 15  # 起き上がり直後、攻撃が当たらない時間
const KNOCKBACK_HIT := 30.0  # 被弾で押される距離(px)
const KNOCKBACK_DOWN := 60.0  # ダウンで押される距離(px)
const BODY_HALF_WIDTH := 20.0


static func total_frames(kind: Kind) -> int:
	var d: Dictionary = DATA[kind]
	return d.startup + d.active + d.recovery
