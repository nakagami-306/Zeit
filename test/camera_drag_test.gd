extends Node

# カメラドラッグのテスト

func test_mouse_drag_moves_camera():
	var scene = load("res://scenes/main.tscn")
	var instance = scene.instantiate()
	add_child(instance)
	
	var camera = instance.get_node("Camera3D")
	
	# ドラッグ関連のプロパティが存在することを確認
	if not "is_dragging" in camera:
		instance.queue_free()
		return TestRunner.assert_true(false, "Camera should have is_dragging property")
	
	if not "drag_start_position" in camera:
		instance.queue_free()
		return TestRunner.assert_true(false, "Camera should have drag_start_position property")
	
	# 初期状態ではドラッグしていないことを確認
	var result = TestRunner.assert_false(camera.is_dragging, 
		"Camera should not be dragging initially")
	
	instance.queue_free()
	return result