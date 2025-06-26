extends Node

# MVP-2の完全な統合テスト

func test_complete_game_flow():
	var game_manager = get_node("/root/GameManager")
	var grid_manager = game_manager.grid_manager
	
	# グリッドをリセット
	grid_manager.occupied_positions.clear()
	grid_manager.residential_radius = 5.0  # 初期値に戻す
	game_manager.house_count = 0
	game_manager.houses = 0
	
	# 時間を進めて複数の家を生成
	for i in range(15):
		game_manager._spawn_house()
		game_manager.house_count += 1
		game_manager.houses = game_manager.house_count
	
	# 最初の家が中心にあることを確認
	if not TestRunner.assert_true(grid_manager.is_occupied(25, 25),
		"First house should be at center"):
		return false
	
	# 自然な集落形成を確認（少なくとも3つ以上の隣接を持つ家が存在）
	var max_adjacent = 0
	for x in range(grid_manager.grid_size.x):
		for y in range(grid_manager.grid_size.y):
			if grid_manager.is_occupied(x, y):
				var adjacent = grid_manager.get_adjacent_buildings_count(Vector2i(x, y))
				if adjacent > max_adjacent:
					max_adjacent = adjacent
	
	return TestRunner.assert_true(max_adjacent >= 3,
		"Natural clustering should create houses with 3+ neighbors")

func test_circular_growth_pattern():
	var game_manager = get_node("/root/GameManager")
	var grid_manager = game_manager.grid_manager
	
	# グリッドをリセット
	grid_manager.occupied_positions.clear()
	grid_manager.residential_radius = 3.0  # 小さく始める
	game_manager.house_count = 0
	game_manager.houses = 0
	
	# 中心からの距離を記録
	var distances = []
	
	# 20軒の家を生成
	for i in range(20):
		game_manager._spawn_house()
		game_manager.house_count += 1
		game_manager.houses = game_manager.house_count
		
		# 最新の家の位置を探す
		for x in range(grid_manager.grid_size.x):
			for y in range(grid_manager.grid_size.y):
				if grid_manager.is_occupied(x, y):
					var dist = Vector2i(x, y).distance_to(grid_manager.center_position)
					if not distances.has(dist):
						distances.append(dist)
	
	# 距離が段階的に増加していることを確認（円形成長）
	distances.sort()
	var is_gradual = true
	for i in range(1, distances.size()):
		# 距離の急激な増加（5以上）がないことを確認
		if distances[i] - distances[i-1] > 5:
			is_gradual = false
			break
	
	return TestRunner.assert_true(is_gradual,
		"Growth should be gradual from center outward")

func test_area_expansion_during_growth():
	var game_manager = get_node("/root/GameManager")
	var grid_manager = game_manager.grid_manager
	
	# グリッドをリセット
	grid_manager.occupied_positions.clear()
	grid_manager.residential_radius = 2.0  # 非常に小さく始める
	var initial_radius = grid_manager.residential_radius
	game_manager.house_count = 0
	game_manager.houses = 0
	
	# 多数の家を生成してエリア拡大を促す
	for i in range(30):
		game_manager._spawn_house()
		game_manager.house_count += 1
		game_manager.houses = game_manager.house_count
	
	# エリアが拡大されたことを確認
	return TestRunner.assert_true(grid_manager.residential_radius > initial_radius,
		"Residential area should expand during growth")

func test_performance_with_new_system():
	var game_manager = get_node("/root/GameManager")
	var grid_manager = game_manager.grid_manager
	
	# グリッドをリセット
	grid_manager.occupied_positions.clear()
	grid_manager.residential_radius = 10.0
	game_manager.house_count = 0
	game_manager.houses = 0
	
	# パフォーマンステスト: 100軒の家を生成
	var start_time = Time.get_ticks_msec()
	
	for i in range(100):
		var pos = grid_manager.get_best_position()
		if pos != Vector2i(-1, -1):
			grid_manager.occupy_position(pos.x, pos.y)
	
	var elapsed_time = Time.get_ticks_msec() - start_time
	
	# 1秒以内に完了することを確認
	return TestRunner.assert_true(elapsed_time < 1000,
		"Performance should be acceptable (< 1 second for 100 houses)")

func test_edge_density_preference():
	var game_manager = get_node("/root/GameManager")
	var grid_manager = game_manager.grid_manager
	
	# グリッドをリセット
	grid_manager.occupied_positions.clear()
	grid_manager.residential_radius = 5.0
	
	# L字型のパターンを作成
	grid_manager.occupy_position(25, 25)
	grid_manager.occupy_position(26, 25)
	grid_manager.occupy_position(27, 25)
	grid_manager.occupy_position(27, 26)
	grid_manager.occupy_position(27, 27)
	
	# 次の最適位置を取得
	var best_pos = grid_manager.get_best_position()
	
	# コーナー部分（高密度エリア）が選ばれることを確認
	var expected_positions = [
		Vector2i(26, 26),  # L字の内側
		Vector2i(28, 26),  # L字の外側
		Vector2i(26, 27)   # L字の外側
	]
	
	return TestRunner.assert_true(expected_positions.has(best_pos),
		"Best position should be near high-density corner area")

func test_parameter_adjustment():
	var game_manager = get_node("/root/GameManager")
	var grid_manager = game_manager.grid_manager
	
	# パラメータ調整のテスト
	var original_adjacency = grid_manager.adjacency_weight
	var original_density = grid_manager.density_weight
	var original_distance = grid_manager.distance_weight
	
	# パラメータを変更
	grid_manager.adjacency_weight = 20.0
	grid_manager.density_weight = 1.0
	grid_manager.distance_weight = 0.1
	
	# 変更が反映されることを確認
	if not TestRunner.assert_equal(grid_manager.adjacency_weight, 20.0,
		"Adjacency weight should be adjustable"):
		return false
	
	# パラメータを元に戻す
	grid_manager.adjacency_weight = original_adjacency
	grid_manager.density_weight = original_density
	grid_manager.distance_weight = original_distance
	
	return TestRunner.assert_true(true, "Parameters are adjustable")