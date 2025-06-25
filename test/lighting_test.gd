extends Node

# ライティングのテスト

func test_scene_has_lighting():
	var scene = load("res://scenes/main.tscn")
	var instance = scene.instantiate()
	
	# DirectionalLight3Dが存在することを確認
	var light = instance.get_node_or_null("DirectionalLight3D")
	if not TestRunner.assert_not_null(light, "DirectionalLight3D should exist in main scene"):
		instance.queue_free()
		return false
	
	# ライトの角度を確認（約-45度, -45度）
	var rotation = light.rotation_degrees
	var x_angle_correct = abs(rotation.x - (-45)) < 1.0
	var y_angle_correct = abs(rotation.y - 45) < 1.0
	
	# 影が有効であることを確認
	var shadow_enabled = light.shadow_enabled
	
	instance.queue_free()
	
	if not TestRunner.assert_true(x_angle_correct, "Light X rotation should be around -45 degrees (got: " + str(rotation.x) + ")"):
		return false
	if not TestRunner.assert_true(y_angle_correct, "Light Y rotation should be around 45 degrees (got: " + str(rotation.y) + ")"):
		return false
	return TestRunner.assert_true(shadow_enabled, "Shadow should be enabled")