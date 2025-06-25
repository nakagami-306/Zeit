extends Node

# UI経過時間表示のテスト

func test_elapsed_time_format():
	# UIシーンをロード
	var ui_scene = load("res://scenes/ui.tscn")
	var ui_instance = ui_scene.instantiate()
	add_child(ui_instance)
	
	# GameManagerを取得
	var game_manager = get_node("/root/GameManager")
	
	# 時間ラベルを取得
	var time_label = ui_instance.get_node("VBoxContainer/TimeLabel")
	if not TestRunner.assert_not_null(time_label, "TimeLabel should exist"):
		ui_instance.queue_free()
		return false
	
	# MM:SS形式のテスト
	game_manager.elapsed_time = 125.0  # 2分5秒
	await get_tree().process_frame
	if not TestRunner.assert_equal(time_label.text, "02:05", 
		"Time should display as MM:SS format"):
		ui_instance.queue_free()
		return false
	
	# HH:MM:SS形式のテスト（1時間以上）
	game_manager.elapsed_time = 3665.0  # 1時間1分5秒
	await get_tree().process_frame
	
	var result = TestRunner.assert_equal(time_label.text, "01:01:05", 
		"Time should display as HH:MM:SS format when over 1 hour")
	
	ui_instance.queue_free()
	return result