class_name Hud
extends CanvasLayer
## 体力・残り時間・連勝・中央メッセージ・操作アイコン。値を受け取って表示するだけ。

var _hp1: ProgressBar
var _hp2: ProgressBar
var _timer: Label
var _streak: Label
var _best: Label
var _message: Label


func _ready() -> void:
	_hp1 = _make_bar(Vector2(40, 30), false)
	_hp2 = _make_bar(Vector2(1152 - 40 - 460, 30), true)
	_timer = _make_label(Vector2(0, 20), 48, HORIZONTAL_ALIGNMENT_CENTER)
	_timer.size.x = 1152
	_streak = _make_label(Vector2(40, 70), 24, HORIZONTAL_ALIGNMENT_LEFT)
	_best = _make_label(Vector2(40, 100), 20, HORIZONTAL_ALIGNMENT_LEFT)
	_best.modulate = Color(1, 1, 1, 0.6)
	_message = _make_label(Vector2(0, 240), 96, HORIZONTAL_ALIGNMENT_CENTER)
	_message.size.x = 1152
	var help := _make_label(Vector2(0, 600), 20, HORIZONTAL_ALIGNMENT_CENTER)
	help.size.x = 1152
	help.text = "←→ 移動    ↓ しゃがみ    [Z] 上段    [X] 下段    [C] 投げ"
	help.modulate = Color(1, 1, 1, 0.7)


func set_hp(hp1: int, hp2: int) -> void:
	_hp1.value = hp1
	_hp2.value = hp2


func set_time(seconds: float) -> void:
	_timer.text = str(ceili(seconds))


func set_streak(streak: int, best: int) -> void:
	_streak.text = "%d WIN STREAK" % streak
	_best.text = "BEST: %d" % best


func set_message(text: String) -> void:
	_message.text = text


func _make_bar(pos: Vector2, right_to_left: bool) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.position = pos
	bar.size = Vector2(460, 28)
	bar.max_value = Moves.MAX_HP
	bar.value = Moves.MAX_HP
	bar.show_percentage = false
	bar.fill_mode = ProgressBar.FILL_END_TO_BEGIN if right_to_left else ProgressBar.FILL_BEGIN_TO_END
	var fill := StyleBoxFlat.new()
	fill.bg_color = Color(1.0, 0.85, 0.2)
	bar.add_theme_stylebox_override("fill", fill)
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0.25, 0.1, 0.1)
	bar.add_theme_stylebox_override("background", bg)
	add_child(bar)
	return bar


func _make_label(pos: Vector2, font_size: int, align: HorizontalAlignment) -> Label:
	var label := Label.new()
	label.position = pos
	label.add_theme_font_size_override("font_size", font_size)
	label.horizontal_alignment = align
	add_child(label)
	return label
