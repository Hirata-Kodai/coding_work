class_name PvHud
extends CanvasLayer
## PV 用の表示。体力バーとキャプションだけ。操作説明や連勝カウンタは出さない。

const WIDTH := 1152.0

var _hp1: ProgressBar
var _hp2: ProgressBar
var _caption: Label
var _title: Label
var _current := ""


func _ready() -> void:
	_hp1 = _make_bar(Vector2(40, 30), false)
	_hp2 = _make_bar(Vector2(WIDTH - 40 - 460, 30), true)
	_caption = _make_label(Vector2(0, 552), 44)
	_title = _make_label(Vector2(0, 230), 92)
	_title.modulate.a = 0.0


func set_hp(hp1: int, hp2: int) -> void:
	_hp1.value = hp1
	_hp2.value = hp2


func set_bars_visible(shown: bool) -> void:
	_hp1.visible = shown
	_hp2.visible = shown


## 同じ文字なら何もしない（毎フレーム呼ばれるため）。
func set_caption(text: String) -> void:
	if text == _current:
		return
	_current = text
	_caption.text = text
	_caption.modulate.a = 0.0
	if text != "":
		_caption.create_tween().tween_property(_caption, "modulate:a", 1.0, 0.15)


func show_title(text: String) -> void:
	_title.text = text
	_title.create_tween().tween_property(_title, "modulate:a", 1.0, 0.3)


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


func _make_label(pos: Vector2, font_size: int) -> Label:
	var label := Label.new()
	label.position = pos
	label.size.x = WIDTH
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	label.add_theme_constant_override("outline_size", 10)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(label)
	return label
