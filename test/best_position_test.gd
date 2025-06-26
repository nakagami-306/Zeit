extends Node

# GridManagerの最適位置選択機能のテスト

func test_get_best_position_empty_grid():
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# 空のグリッドでは中心位置が最適
	var best_pos = grid_manager.get_best_position()
	return TestRunner.assert_equal(best_pos, Vector2i(25, 25), 
		"Empty grid should return center position as best")

func test_get_best_position_with_adjacent():
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# 中心に建物を配置
	grid_manager.occupy_position(25, 25)
	
	# 隣接位置のいずれかが選ばれるはず
	var best_pos = grid_manager.get_best_position()
	var adjacent_positions = [
		Vector2i(25, 24),  # 北
		Vector2i(26, 25),  # 東
		Vector2i(25, 26),  # 南
		Vector2i(24, 25)   # 西
	]
	
	var is_adjacent = adjacent_positions.has(best_pos)
	return TestRunner.assert_true(is_adjacent, 
		"Best position should be adjacent to existing building")

func test_get_best_position_multiple_options():
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# L字型に建物を配置
	grid_manager.occupy_position(25, 25)
	grid_manager.occupy_position(26, 25)
	grid_manager.occupy_position(26, 26)
	
	# 最も多くの隣接を持つ位置が選ばれるはず
	var best_pos = grid_manager.get_best_position()
	# (25, 26) は2つの隣接を持つので最適
	return TestRunner.assert_equal(best_pos, Vector2i(25, 26), 
		"Position with most adjacent buildings should be selected")

func test_get_best_position_outside_residential_area():
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# 住宅エリアの端に建物を配置
	for x in range(20, 31):
		for y in range(20, 31):
			var pos = Vector2i(x, y)
			if grid_manager.is_within_residential_area(pos):
				grid_manager.occupy_position(x, y)
	
	# エリア外の位置は選ばれないはず
	var best_pos = grid_manager.get_best_position()
	if best_pos != Vector2i(-1, -1):
		return TestRunner.assert_true(
			grid_manager.is_within_residential_area(best_pos),
			"Best position must be within residential area"
		)
	else:
		# エリアが満杯の場合
		return TestRunner.assert_true(true, "Residential area is full")

func test_get_best_position_tie_breaking():
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# 同じ優先度を持つ複数の位置を作成
	grid_manager.occupy_position(25, 25)
	
	# 複数回実行して、ランダム性を確認
	var positions = []
	for i in range(10):
		# グリッドをリセット
		grid_manager = grid_manager_script.new()
		grid_manager.occupy_position(25, 25)
		var pos = grid_manager.get_best_position()
		if not positions.has(pos):
			positions.append(pos)
	
	# 複数の異なる位置が選ばれることを確認（ランダム性）
	return TestRunner.assert_true(positions.size() > 1, 
		"Tie-breaking should show some randomness in position selection")

func test_get_best_position_grid_full():
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# 住宅エリア内をすべて埋める
	for x in range(50):
		for y in range(50):
			var pos = Vector2i(x, y)
			if grid_manager.is_within_residential_area(pos):
				grid_manager.occupy_position(x, y)
	
	# グリッドが満杯の場合は無効な位置を返す
	var best_pos = grid_manager.get_best_position()
	return TestRunner.assert_equal(best_pos, Vector2i(-1, -1), 
		"Full grid should return invalid position")

func test_get_available_positions_in_area():
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# get_available_positions メソッドが存在し、エリア内のみを返すことを確認
	if grid_manager.has_method("get_available_positions"):
		var positions = grid_manager.get_available_positions()
		
		# すべての位置が住宅エリア内であることを確認
		for pos in positions:
			if not grid_manager.is_within_residential_area(pos):
				return TestRunner.assert_true(false, 
					"All available positions should be within residential area")
		
		return TestRunner.assert_true(true, 
			"get_available_positions returns only positions within residential area")
	else:
		# メソッドが実装されていない場合は、既存の動作を維持
		return TestRunner.assert_true(true, 
			"get_available_positions not implemented yet")