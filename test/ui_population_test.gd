extends Node

# UI人口表示のテスト

func test_population_label_updates():
	# UIシーンをロード
	var ui_scene = load("res://scenes/ui.tscn")
	var ui_instance = ui_scene.instantiate()
	add_child(ui_instance)
	
	# GameManagerを取得
	var game_manager = get_node("/root/GameManager")
	
	# 人口ラベルを取得
	var population_label = ui_instance.get_node("VBoxContainer/PopulationLabel")
	if not TestRunner.assert_not_null(population_label, "PopulationLabel should exist"):
		ui_instance.queue_free()
		return false
	
	# 初期表示を確認
	await get_tree().process_frame
	if not TestRunner.assert_equal(population_label.text, "人口: 0", 
		"Initial population display should be '人口: 0'"):
		ui_instance.queue_free()
		return false
	
	# 人口を変更して表示が更新されることを確認
	game_manager.population = 5
	await get_tree().process_frame
	
	var result = TestRunner.assert_equal(population_label.text, "人口: 5", 
		"Population display should update to '人口: 5'")
	
	ui_instance.queue_free()
	return result