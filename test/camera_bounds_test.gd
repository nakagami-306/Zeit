extends Node

# カメラ移動範囲制限のテスト

func test_camera_stays_within_bounds():
	var scene = load("res://scenes/main.tscn")
	var instance = scene.instantiate()
	add_child(instance)
	
	var camera = instance.get_node("Camera3D")
	
	# _clamp_positionメソッドが存在することを確認
	if not TestRunner.assert_true(camera.has_method("_clamp_position"), 
		"Camera should have _clamp_position method"):
		instance.queue_free()
		return false
	
	# 範囲外の位置を設定してクランプされることを確認
	camera.position = Vector3(100, 100, 100)
	camera._clamp_position()
	
	# X座標が範囲内にクランプされていることを確認
	if not TestRunner.assert_true(camera.position.x <= 35, 
		"Camera X position should be clamped to max 35"):
		instance.queue_free()
		return false
	
	# Z座標が範囲内にクランプされていることを確認
	if not TestRunner.assert_true(camera.position.z <= 35, 
		"Camera Z position should be clamped to max 35"):
		instance.queue_free()
		return false
	
	# Y座標が10に固定されていることを確認
	var result = TestRunner.assert_equal(camera.position.y, 10.0, 
		"Camera Y position should be fixed at 10")
	
	instance.queue_free()
	return result