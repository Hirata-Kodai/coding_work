class_name FighterCore
extends RefCounted
## 1体分の状態機械。シーンに依存せず、step() で1フレーム進む。
## Input は直接読まない。Main から入力辞書を渡される。

enum State { IDLE, WALK, CROUCH, ATTACK, HITSTUN, DOWN }

const STATE_NAMES := {
	State.IDLE: "idle",
	State.WALK: "walk",
	State.CROUCH: "crouch",
	State.HITSTUN: "hitstun",
	State.DOWN: "down",
}

var x: float
var facing: int  # 1 = 右向き, -1 = 左向き
var hp: int = Moves.MAX_HP
var state: State = State.IDLE
var move: Moves.Kind = Moves.Kind.HIGH  # ATTACK 中のみ有効
var frame: int = 0  # 現在の状態に入ってからのフレーム数
var combo_count: int = 0  # 被弾側で数える連続ヒット数。硬直が切れたら0
var has_hit: bool = false  # この攻撃が既に当たったか（多段ヒット防止）
var min_x: float = -INF
var max_x: float = INF

var _prev_input: Dictionary = empty_input()


func _init(start_x: float, start_facing: int) -> void:
	x = start_x
	facing = start_facing


static func empty_input() -> Dictionary:
	return {"left": false, "right": false, "down": false, "high": false, "low": false, "throw": false}


func step(input: Dictionary) -> void:
	match state:
		State.IDLE, State.WALK, State.CROUCH:
			_step_free(input)
		State.ATTACK:
			frame += 1
			if frame >= Moves.total_frames(move):
				_enter(State.IDLE)
		State.HITSTUN:
			frame += 1
			if frame >= Moves.HITSTUN_FRAMES:
				combo_count = 0
				_enter(State.IDLE)
		State.DOWN:
			frame += 1
			if frame >= Moves.DOWN_FRAMES:
				combo_count = 0
				_enter(State.IDLE)
	_prev_input = input.duplicate()


func _step_free(input: Dictionary) -> void:
	var pressed_move := _newly_pressed_move(input)
	if pressed_move != -1:
		move = pressed_move as Moves.Kind
		has_hit = false
		_enter(State.ATTACK)
		return
	if input.down:
		_enter(State.CROUCH)
		return
	var dir := int(input.right) - int(input.left)
	if dir != 0:
		x = clampf(x + dir * Moves.MOVE_SPEED, min_x, max_x)
		_enter(State.WALK)
	else:
		_enter(State.IDLE)


## 押しっぱなしでは技が出ない。このフレームで新たに押されたボタンだけ拾う。
func _newly_pressed_move(input: Dictionary) -> int:
	for pair in [["high", Moves.Kind.HIGH], ["low", Moves.Kind.LOW], ["throw", Moves.Kind.THROW]]:
		if input[pair[0]] and not _prev_input[pair[0]]:
			return pair[1]
	return -1


func _enter(new_state: State) -> void:
	if state != new_state or new_state == State.ATTACK:
		frame = 0
	state = new_state


func is_attack_active() -> bool:
	if state != State.ATTACK:
		return false
	var d: Dictionary = Moves.DATA[move]
	return frame >= d.startup and frame < d.startup + d.active


## 攻撃判定の先端の x 座標。
func attack_front_x() -> float:
	return x + facing * (Moves.BODY_HALF_WIDTH + Moves.DATA[move].reach)


func take_hit(damage: int, knockdown: bool) -> void:
	hp = maxi(hp - damage, 0)
	combo_count += 1
	frame = 0
	state = State.DOWN if knockdown else State.HITSTUN


func get_state_dict() -> Dictionary:
	var name: String = STATE_NAMES.get(state, "")
	if state == State.ATTACK:
		name = "attack_" + Moves.DATA[move].name
	return {"x": x, "hp": hp, "state": name}
