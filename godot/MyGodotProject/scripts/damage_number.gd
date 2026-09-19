class_name DamageNumber
extends Label
## 被弾位置から上へ飛んで 0.4 秒で消える数字。連続ヒットは赤く大きく「N HIT!」付き。


static func spawn(parent: Node, pos: Vector2, damage: int, hit_count: int) -> void:
	var n := DamageNumber.new()
	n.text = str(damage)
	var font_size := 40
	if hit_count >= 2:
		n.text += "  %d HIT!" % hit_count
		n.modulate = Color(1.0, 0.3, 0.2)
		font_size = 40 + 8 * mini(hit_count, 5)
	n.add_theme_font_size_override("font_size", font_size)
	n.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	n.position = pos + Vector2(-100, -40)
	n.size.x = 200
	parent.add_child(n)
	var tween := n.create_tween().set_parallel(true)
	tween.tween_property(n, "position:y", n.position.y - 80, 0.4).set_ease(Tween.EASE_OUT)
	tween.tween_property(n, "modulate:a", 0.0, 0.4).set_delay(0.15)
	tween.chain().tween_callback(n.queue_free)
