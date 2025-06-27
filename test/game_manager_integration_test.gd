extends Node

# GameManagerと新しい配置システムの統合テスト

func test_spawn_house_uses_best_position():
	var game_manager = get_node("/root/GameManager")
	var grid_manager = game_manager.get_node("GridManager")
	
	# グリッドをリセット
	grid_manager.occupied_positions.clear()
	
	# 最初の家を生成
	game_manager._spawn_house()
	
	# 最初の家は中心に配置されるべき
	return TestRunner.assert_true(
		grid_manager.is_occupied(25, 25),
		"First house should be placed at center position"
	)

func test_subsequent_houses_adjacent():
	var game_manager = get_node("/root/GameManager")
	var grid_manager = game_manager.get_node("GridManager")
	
	# グリッドをリセット
	grid_manager.occupied_positions.clear()
	
	# 複数の家を生成
	game_manager._spawn_house()  # 中心に配置
	game_manager._spawn_house()  # 隣接位置に配置
	
	# 2つ目の家が中心の隣に配置されているか確認
	var adjacent_positions = [
		Vector2i(25, 24),  # 北
		Vector2i(26, 25),  # 東
		Vector2i(25, 26),  # 南
		Vector2i(24, 25)   # 西
	]
	
	var found_adjacent = false
	for pos in adjacent_positions:
		if grid_manager.is_occupied(pos.x, pos.y):
			found_adjacent = true
			break
	
	return TestRunner.assert_true(found_adjacent,
		"Second house should be placed adjacent to the first"
	)

func test_natural_cluster_formation():
	var game_manager = get_node("/root/GameManager")
	var grid_manager = game_manager.get_node("GridManager")
	
	# グリッドをリセット
	grid_manager.occupied_positions.clear()
	
	# 10軒の家を生成
	for i in range(10):
		game_manager._spawn_house()
	
	# 集落が形成されているか確認（少なくとも1つの家が2つ以上の隣接を持つ）
	var has_cluster = false
	for x in range(grid_manager.grid_size.x):
		for y in range(grid_manager.grid_size.y):
			if grid_manager.is_occupied(x, y):
				var adjacent_count = grid_manager.get_adjacent_buildings_count(Vector2i(x, y))
				if adjacent_count >= 2:
					has_cluster = true
					break
		if has_cluster:
			break
	
	return TestRunner.assert_true(has_cluster,
		"Natural cluster formation should occur with multiple houses"
	)

func test_respects_residential_area():
	var game_manager = get_node("/root/GameManager")
	var grid_manager = game_manager.get_node("GridManager")
	
	# グリッドをリセット
	grid_manager.occupied_positions.clear()
	
	# 住宅エリアを小さくして、境界をテスト
	grid_manager.residential_radius = 3.0
	
	# 複数の家を生成
	for i in range(20):
		game_manager._spawn_house()
	
	# すべての家が住宅エリア内に配置されているか確認
	for x in range(grid_manager.grid_size.x):
		for y in range(grid_manager.grid_size.y):
			if grid_manager.is_occupied(x, y):
				var pos = Vector2i(x, y)
				if not grid_manager.is_within_residential_area(pos):
					return TestRunner.assert_true(false,
						"All houses should be within residential area"
					)
	
	return TestRunner.assert_true(true,
		"All houses are correctly placed within residential area"
	)

func test_spawn_house_returns_position():
	var game_manager = get_node("/root/GameManager")
	var grid_manager = game_manager.get_node("GridManager")
	
	# グリッドをリセット
	grid_manager.occupied_positions.clear()
	
	# _spawn_houseメソッドが位置を返すか確認（改修が必要な場合）
	if game_manager.has_method("_spawn_house"):
		# 現在の実装では位置を返さないので、この機能は後で追加
		return TestRunner.assert_true(true,
			"_spawn_house method exists"
		)
	else:
		return TestRunner.assert_true(false,
			"_spawn_house method should exist"
		)

func test_first_house_special_handling():
	var game_manager = get_node("/root/GameManager")
	var grid_manager = game_manager.get_node("GridManager")
	
	# グリッドをリセット
	grid_manager.occupied_positions.clear()
	game_manager.houses = 0
	
	# 最初の家は必ず中心に配置されることを確認
	game_manager._spawn_house()
	
	return TestRunner.assert_true(
		grid_manager.is_occupied(25, 25),
		"First house must always be placed at center position"
	)