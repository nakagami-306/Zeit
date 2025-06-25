extends Node

# カメラコントローラーのテスト

func test_camera_controller_exists():
	var scene = load("res://scenes/main.tscn")
	var instance = scene.instantiate()
	
	# Camera3Dを取得
	var camera = instance.get_node_or_null("Camera3D")
	if not TestRunner.assert_not_null(camera, "Camera3D should exist"):
		instance.queue_free()
		return false
	
	# CameraControllerスクリプトがアタッチされていることを確認
	if not TestRunner.assert_true(camera.has_method("_input"), 
		"Camera should have CameraController script attached"):
		instance.queue_free()
		return false
	
	instance.queue_free()
	return true