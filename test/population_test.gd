extends Node

# 人口管理システムのテスト

func test_population_increases_after_10_seconds():
	var game_manager = get_node("/root/GameManager")
	if not game_manager:
		return false
	
	# タイマーノードが存在することを確認
	var timer = game_manager.get_node_or_null("PopulationTimer")
	if not TestRunner.assert_not_null(timer, "PopulationTimer should exist in GameManager"):
		return false
	
	# タイマーの設定を確認
	if not TestRunner.assert_equal(timer.wait_time, 10.0, "Timer wait_time should be 10 seconds"):
		return false
	
	# タイマーが自動スタートすることを確認
	return TestRunner.assert_true(timer.autostart, "Timer should autostart")

func test_population_increase_signal():
	var game_manager = get_node("/root/GameManager")
	if not game_manager:
		return false
	
	# 初期人口を確認
	var initial_population = game_manager.population
	
	# _on_population_timer_timeoutメソッドが存在することを確認
	if not TestRunner.assert_true(game_manager.has_method("_on_population_timer_timeout"), 
		"GameManager should have _on_population_timer_timeout method"):
		return false
	
	# メソッドを呼び出して人口が増加することを確認
	game_manager._on_population_timer_timeout()
	
	return TestRunner.assert_equal(game_manager.population, initial_population + 1, 
		"Population should increase by 1 when timer triggers")