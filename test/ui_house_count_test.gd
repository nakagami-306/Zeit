extends Node

# UI家の数表示のテスト

func test_house_count_label_updates():
	# UIシーンをロード
	var ui_scene = load("res://scenes/ui.tscn")
	var ui_instance = ui_scene.instantiate()
	add_child(ui_instance)
	
	# GameManagerを取得
	var game_manager = get_node("/root/GameManager")
	
	# 家の数ラベルを取得
	var house_count_label = ui_instance.get_node("VBoxContainer/HouseCountLabel")
	if not TestRunner.assert_not_null(house_count_label, "HouseCountLabel should exist"):
		ui_instance.queue_free()
		return false
	
	# 初期表示を確認
	await get_tree().process_frame
	if not TestRunner.assert_equal(house_count_label.text, "家: 0", 
		"Initial house count display should be '家: 0'"):
		ui_instance.queue_free()
		return false
	
	# 家の数を変更して表示が更新されることを確認
	game_manager.house_count = 3
	await get_tree().process_frame
	
	var result = TestRunner.assert_equal(house_count_label.text, "家: 3", 
		"House count display should update to '家: 3'")
	
	ui_instance.queue_free()
	return result