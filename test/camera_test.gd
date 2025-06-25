extends Node

# カメラのテスト

func test_camera_is_isometric():
	var scene = load("res://scenes/main.tscn")
	var instance = scene.instantiate()
	
	# カメラが存在することを確認
	var camera = instance.get_node_or_null("Camera3D")
	if not TestRunner.assert_not_null(camera, "Camera3D should exist in main scene"):
		instance.queue_free()
		return false
	
	# カメラの角度を確認（アイソメトリック角度）
	var rotation = camera.rotation_degrees
	var x_angle_correct = abs(rotation.x - (-45)) < 1.0
	var y_angle_correct = abs(rotation.y - 45) < 1.0
	
	instance.queue_free()
	
	if not TestRunner.assert_true(x_angle_correct, "Camera X rotation should be around -45 degrees (got: " + str(rotation.x) + ")"):
		return false
	return TestRunner.assert_true(y_angle_correct, "Camera Y rotation should be around 45 degrees (got: " + str(rotation.y) + ")")

func test_camera_is_orthogonal():
	var scene = load("res://scenes/main.tscn")
	var instance = scene.instantiate()
	
	var camera = instance.get_node_or_null("Camera3D")
	if not camera:
		instance.queue_free()
		return false
	
	# 正投影であることを確認
	var is_orthogonal = camera.projection == Camera3D.PROJECTION_ORTHOGONAL
	
	# サイズが10であることを確認
	var size_correct = abs(camera.size - 10.0) < 0.1
	
	instance.queue_free()
	
	if not TestRunner.assert_true(is_orthogonal, "Camera should use orthogonal projection"):
		return false
	return TestRunner.assert_true(size_correct, "Camera size should be 10 (got: " + str(camera.size) + ")")