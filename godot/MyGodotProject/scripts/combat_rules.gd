class_name CombatRules
## 3すくみとダメージ計算。状態を持たない純粋関数のみ。

enum Outcome { WIN, LOSE, TRADE }

const COMEBACK_HP := 40
const COMEBACK_MULT := 1.5
const COMBO_MULT := [1.0, 1.2, 1.4, 1.5]  # 1発目, 2発目, 3発目, 4発目以降

## attacker の技が defender の技に対して勝つか。上段 < 下段 < 投げ < 上段。
static func compare(attacker: Moves.Kind, defender: Moves.Kind) -> Outcome:
	if attacker == defender:
		return Outcome.TRADE
	var beats := {
		Moves.Kind.HIGH: Moves.Kind.THROW,
		Moves.Kind.LOW: Moves.Kind.HIGH,
		Moves.Kind.THROW: Moves.Kind.LOW,
	}
	return Outcome.WIN if beats[attacker] == defender else Outcome.LOSE


## しゃがみで避けられる技は上段のみ。
static func crouch_avoids(kind: Moves.Kind) -> bool:
	return kind == Moves.Kind.HIGH


## hit_count は今回の攻撃が連続何発目か(1始まり)。attacker_hp は攻撃側の残り体力。
static func damage(base: int, hit_count: int, attacker_hp: int) -> int:
	var idx: int = clampi(hit_count - 1, 0, COMBO_MULT.size() - 1)
	var mult: float = COMBO_MULT[idx]
	if attacker_hp <= COMEBACK_HP:
		mult *= COMEBACK_MULT
	return floori(base * mult + 0.0001)  # 浮動小数誤差で 53.999 にならないよう補正


## 効果音の音程。1発目1.0、以降0.08ずつ上がり1.4で打ち止め。
static func pitch_scale(hit_count: int) -> float:
	return 1.0 + 0.08 * mini(hit_count - 1, 5)
