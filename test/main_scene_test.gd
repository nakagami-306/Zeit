extends Node

# メインシーンの存在確認テスト

func test_main_scene_exists():
	var scene_path = "res://scenes/main.tscn"
	var file_exists = FileAccess.file_exists(scene_path)
	return TestRunner.assert_true(file_exists, "Main scene should exist at: " + scene_path)

func test_main_scene_is_node3d():
	var scene_path = "res://scenes/main.tscn"
	if not FileAccess.file_exists(scene_path):
		return false
	
	var scene = load(scene_path)
	if not scene:
		return TestRunner.assert_not_null(scene, "Main scene should be loadable")
	
	var instance = scene.instantiate()
	var is_node3d = instance is Node3D
	instance.queue_free()
	return TestRunner.assert_true(is_node3d, "Main scene root should be Node3D")