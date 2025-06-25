extends Node

# 地面のテスト

func test_ground_exists():
	var scene = load("res://scenes/main.tscn")
	var instance = scene.instantiate()
	
	# CSGBox3Dが存在することを確認
	var ground = instance.get_node_or_null("Ground")
	if not TestRunner.assert_not_null(ground, "Ground (CSGBox3D) should exist in main scene"):
		instance.queue_free()
		return false
	
	# CSGBox3Dであることを確認
	if not TestRunner.assert_true(ground is CSGBox3D, "Ground should be CSGBox3D"):
		instance.queue_free()
		return false
	
	# サイズを確認（50x0.1x50）
	var size = ground.size
	var size_correct = abs(size.x - 50) < 0.1 and abs(size.y - 0.1) < 0.01 and abs(size.z - 50) < 0.1
	
	# マテリアルが設定されていることを確認
	var has_material = ground.material != null
	
	instance.queue_free()
	
	if not TestRunner.assert_true(size_correct, "Ground size should be 50x0.1x50 (got: " + str(size) + ")"):
		return false
	return TestRunner.assert_true(has_material, "Ground should have a material")