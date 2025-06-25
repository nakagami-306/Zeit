extends Node

# 統合テスト

func test_full_game_flow():
	var game_manager = get_node("/root/GameManager")
	
	# 初期状態を設定
	game_manager.population = 0
	game_manager.house_count = 0
	game_manager.time_scale = 100.0  # 高速化してテスト時間を短縮
	
	# 人口0、家0から開始
	if not TestRunner.assert_equal(game_manager.population, 0, "Should start with 0 population"):
		return false
	if not TestRunner.assert_equal(game_manager.house_count, 0, "Should start with 0 houses"):
		return false
	
	# 1人目の追加（家1軒になるはず）
	game_manager._on_population_timer_timeout()
	if not TestRunner.assert_equal(game_manager.population, 1, "Population should be 1"):
		return false
	if not TestRunner.assert_equal(game_manager.house_count, 1, "Should have 1 house at population 1"):
		return false
	
	# 2人目、3人目（家は1軒のまま）
	game_manager._on_population_timer_timeout()
	game_manager._on_population_timer_timeout()
	if not TestRunner.assert_equal(game_manager.population, 3, "Population should be 3"):
		return false
	if not TestRunner.assert_equal(game_manager.house_count, 1, "Should still have 1 house at population 3"):
		return false
	
	# 4人目（家2軒になるはず）
	game_manager._on_population_timer_timeout()
	if not TestRunner.assert_equal(game_manager.population, 4, "Population should be 4"):
		return false
	return TestRunner.assert_equal(game_manager.house_count, 2, "Should have 2 houses at population 4")

func test_ui_reflects_game_state():
	# UIシーンをロード
	var ui_scene = load("res://scenes/ui.tscn")
	var ui_instance = ui_scene.instantiate()
	add_child(ui_instance)
	
	var game_manager = get_node("/root/GameManager")
	
	# ゲーム状態を設定
	game_manager.population = 10
	game_manager.house_count = 5
	game_manager.elapsed_time = 125.0
	
	# UIが更新されるのを待つ
	await get_tree().process_frame
	
	# 各ラベルが正しく表示されているか確認
	var pop_label = ui_instance.get_node("VBoxContainer/PopulationLabel")
	var house_label = ui_instance.get_node("VBoxContainer/HouseCountLabel")
	var time_label = ui_instance.get_node("VBoxContainer/TimeLabel")
	
	var all_correct = true
	if pop_label.text != "人口: 10":
		all_correct = false
	if house_label.text != "家: 5":
		all_correct = false
	if time_label.text != "02:05":
		all_correct = false
	
	ui_instance.queue_free()
	return TestRunner.assert_true(all_correct, "All UI labels should reflect game state")