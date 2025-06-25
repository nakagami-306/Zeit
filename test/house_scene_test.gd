extends Node

# 家のシーンのテスト

func test_house_scene_loads():
	var scene_path = "res://scenes/house.tscn"
	
	# シーンファイルが存在することを確認
	if not TestRunner.assert_true(FileAccess.file_exists(scene_path), 
		"House scene should exist at: " + scene_path):
		return false
	
	# シーンをロードできることを確認
	var scene = load(scene_path)
	if not TestRunner.assert_not_null(scene, "House scene should be loadable"):
		return false
	
	# インスタンス化できることを確認
	var instance = scene.instantiate()
	if not TestRunner.assert_not_null(instance, "House scene should be instantiable"):
		return false
	
	# Node3Dであることを確認
	if not TestRunner.assert_true(instance is Node3D, "House root should be Node3D"):
		instance.queue_free()
		return false
	
	instance.queue_free()
	return true

func test_house_has_mesh():
	var scene_path = "res://scenes/house.tscn"
	if not FileAccess.file_exists(scene_path):
		return false
	
	var scene = load(scene_path)
	var instance = scene.instantiate()
	
	# MeshInstance3Dが存在することを確認
	var mesh_instance = instance.get_node_or_null("MeshInstance3D")
	if not TestRunner.assert_not_null(mesh_instance, "House should have MeshInstance3D"):
		instance.queue_free()
		return false
	
	# メッシュが設定されていることを確認
	if not TestRunner.assert_not_null(mesh_instance.mesh, "MeshInstance3D should have a mesh"):
		instance.queue_free()
		return false
	
	instance.queue_free()
	return true

func test_house_has_collision():
	var scene_path = "res://scenes/house.tscn"
	if not FileAccess.file_exists(scene_path):
		return false
	
	var scene = load(scene_path)
	var instance = scene.instantiate()
	
	# StaticBody3Dが存在することを確認
	var static_body = instance.get_node_or_null("StaticBody3D")
	if not TestRunner.assert_not_null(static_body, "House should have StaticBody3D for collision"):
		instance.queue_free()
		return false
	
	# CollisionShapeが存在することを確認
	var collision_shape = static_body.get_node_or_null("CollisionShape3D")
	if not TestRunner.assert_not_null(collision_shape, "StaticBody3D should have CollisionShape3D"):
		instance.queue_free()
		return false
	
	instance.queue_free()
	return true