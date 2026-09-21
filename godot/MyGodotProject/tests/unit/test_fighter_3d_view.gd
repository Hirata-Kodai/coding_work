extends GutTest

var view: Fighter3DView


func before_each() -> void:
	view = Fighter3DView.new()
	add_child_autofree(view)


func test_library_contains_every_clip() -> void:
	for clip_name in FighterAnim.CLIPS:
		assert_true(view._ap.has_animation(Fighter3DView.LIBRARY + "/" + clip_name), clip_name)


func test_hips_never_move_horizontally() -> void:
	# 技の踏み込みやダウンの後退は MatchCore が管理するので、腰の位置トラックから前後左右を消す
	for clip_name in FighterAnim.CLIPS:
		var anim: Animation = view._ap.get_animation(Fighter3DView.LIBRARY + "/" + clip_name)
		var track := anim.find_track("Skeleton3D:mixamorig_Hips", Animation.TYPE_POSITION_3D)
		if track == -1:
			continue
		var first: Vector3 = anim.track_get_key_value(track, 0)
		for k in anim.track_get_key_count(track):
			var v: Vector3 = anim.track_get_key_value(track, k)
			assert_almost_eq(v.x, first.x, 0.0001, clip_name + " x")
			assert_almost_eq(v.z, first.z, 0.0001, clip_name + " z")


func test_hips_still_move_vertically_when_crouching() -> void:
	var stand: Animation = view._ap.get_animation(Fighter3DView.LIBRARY + "/idle")
	var crouch: Animation = view._ap.get_animation(Fighter3DView.LIBRARY + "/crouch")
	var ts := stand.find_track("Skeleton3D:mixamorig_Hips", Animation.TYPE_POSITION_3D)
	var tc := crouch.find_track("Skeleton3D:mixamorig_Hips", Animation.TYPE_POSITION_3D)
	var y_stand: float = stand.track_get_key_value(ts, 0).y
	var y_crouch: float = crouch.track_get_key_value(tc, 0).y
	assert_lt(y_crouch, y_stand)
