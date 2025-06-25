extends Node

# カメラ移動のテスト

func test_wasd_moves_camera():
	var scene = load("res://scenes/main.tscn")
	var instance = scene.instantiate()
	add_child(instance)
	
	var camera = instance.get_node("Camera3D")
	if not TestRunner.assert_not_null(camera, "Camera3D should exist"):
		instance.queue_free()
		return false
	
	# _processメソッドが存在することを確認
	if not TestRunner.assert_true(camera.has_method("_process"), 
		"Camera should have _process method"):
		instance.queue_free()
		return false
	
	# _handle_keyboard_movementメソッドが存在することを確認
	var result = TestRunner.assert_true(camera.has_method("_handle_keyboard_movement"), 
		"Camera should have _handle_keyboard_movement method")
	
	instance.queue_free()
	return result

func test_camera_movement_speed():
	var scene = load("res://scenes/main.tscn")
	var instance = scene.instantiate()
	add_child(instance)
	
	var camera = instance.get_node("Camera3D")
	
	# movement_speedプロパティが存在することを確認
	if not "movement_speed" in camera:
		instance.queue_free()
		return TestRunner.assert_true(false, "Camera should have movement_speed property")
	
	# デフォルト速度が10であることを確認
	var result = TestRunner.assert_equal(camera.movement_speed, 10.0, 
		"Default movement speed should be 10.0")
	
	instance.queue_free()
	return result