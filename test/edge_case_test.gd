extends Node

# エッジケーステスト

func test_grid_full_scenario():
	var game_manager = get_node("/root/GameManager")
	var grid_manager = game_manager.get_node("GridManager")
	
	# グリッドを完全に埋める
	for x in range(50):
		for y in range(50):
			grid_manager.occupy_position(x, y)
	
	# 新しい位置を取得しようとする
	var pos = grid_manager.get_random_available_position()
	
	# 無効な位置が返されることを確認
	return TestRunner.assert_equal(pos, Vector2i(-1, -1), 
		"Should return invalid position when grid is full")

func test_time_scale_extremes():
	var game_manager = get_node("/root/GameManager")
	
	# 最小値のテスト
	game_manager.set_time_scale(0.1)
	if not TestRunner.assert_equal(game_manager.time_scale, 0.1, 
		"Should handle time_scale 0.1"):
		return false
	
	# 最大値のテスト
	game_manager.set_time_scale(1000.0)
	if not TestRunner.assert_equal(game_manager.time_scale, 1000.0, 
		"Should handle time_scale 1000"):
		return false
	
	# タイマーが正しく更新されることを確認
	var timer = game_manager.get_node("PopulationTimer")
	var expected_wait_time = 10.0 / 1000.0  # 0.01秒
	
	return TestRunner.assert_equal(timer.wait_time, expected_wait_time, 
		"Timer wait_time should be updated correctly")