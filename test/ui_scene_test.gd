extends Node

# UIシーンのテスト

func test_ui_scene_exists():
	var scene_path = "res://scenes/ui.tscn"
	
	# シーンファイルが存在することを確認
	if not TestRunner.assert_true(FileAccess.file_exists(scene_path), 
		"UI scene should exist at: " + scene_path):
		return false
	
	# シーンをロードできることを確認
	var scene = load(scene_path)
	if not TestRunner.assert_not_null(scene, "UI scene should be loadable"):
		return false
	
	# インスタンス化できることを確認
	var instance = scene.instantiate()
	if not TestRunner.assert_not_null(instance, "UI scene should be instantiable"):
		return false
	
	# CanvasLayerであることを確認
	if not TestRunner.assert_true(instance is CanvasLayer, "UI root should be CanvasLayer"):
		instance.queue_free()
		return false
	
	instance.queue_free()
	return true

func test_ui_has_script():
	var scene_path = "res://scenes/ui.tscn"
	if not FileAccess.file_exists(scene_path):
		return false
	
	var scene = load(scene_path)
	var instance = scene.instantiate()
	
	# スクリプトがアタッチされていることを確認
	if not TestRunner.assert_true(instance.has_method("_ready"), 
		"UI should have a script attached"):
		instance.queue_free()
		return false
	
	instance.queue_free()
	return true