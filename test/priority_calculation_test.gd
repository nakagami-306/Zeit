extends Node

# GridManagerの配置優先度計算のテスト

func test_priority_with_no_neighbors():
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# 隣接建物なし、密度0の位置の優先度
	var priority = grid_manager.calculate_placement_priority(Vector2i(25, 25))
	# 中心位置なので距離ペナルティは0、他も0
	return TestRunner.assert_equal(priority, 0.0, 
		"Empty center position should have priority 0")

func test_priority_with_adjacent_buildings():
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# 隣接建物を配置
	grid_manager.occupy_position(25, 24)  # 北に建物
	
	# 隣接ボーナス: 1 * 10 = 10
	var priority = grid_manager.calculate_placement_priority(Vector2i(25, 25))
	return TestRunner.assert_true(priority >= 10.0, 
		"Position with 1 adjacent building should have priority >= 10")

func test_priority_with_multiple_adjacent():
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# 複数の隣接建物を配置
	grid_manager.occupy_position(25, 24)  # 北
	grid_manager.occupy_position(26, 25)  # 東
	grid_manager.occupy_position(25, 26)  # 南
	
	# 隣接ボーナス: 3 * 10 = 30
	var priority = grid_manager.calculate_placement_priority(Vector2i(25, 25))
	return TestRunner.assert_true(priority >= 30.0, 
		"Position with 3 adjacent buildings should have priority >= 30")

func test_priority_with_area_density():
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# 周囲に建物を配置（隣接はなし）
	grid_manager.occupy_position(24, 24)
	grid_manager.occupy_position(26, 24)
	grid_manager.occupy_position(24, 26)
	grid_manager.occupy_position(26, 26)
	
	# 密度: 4/9 ≈ 0.44, 密度ボーナス: 0.44 * 2 ≈ 0.88
	var priority = grid_manager.calculate_placement_priority(Vector2i(25, 25))
	return TestRunner.assert_true(priority > 0.5 and priority < 1.5, 
		"Position with area density should have appropriate priority")

func test_priority_with_distance_penalty():
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# 中心から離れた位置の優先度（隣接なし）
	var priority_far = grid_manager.calculate_placement_priority(Vector2i(30, 30))
	var priority_center = grid_manager.calculate_placement_priority(Vector2i(25, 25))
	
	# 遠い位置は距離ペナルティで優先度が低い
	return TestRunner.assert_true(priority_far < priority_center, 
		"Far position should have lower priority than center due to distance penalty")

func test_priority_combined_factors():
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# 複合的な条件
	grid_manager.occupy_position(20, 20)  # 隣接建物
	grid_manager.occupy_position(19, 19)  # 周囲の建物
	grid_manager.occupy_position(21, 19)  # 周囲の建物
	
	var priority = grid_manager.calculate_placement_priority(Vector2i(20, 19))
	# 隣接: 1 * 10 = 10
	# 密度: 3/9 * 2 ≈ 0.67
	# 距離: -(√50) * 0.5 ≈ -3.5
	# 合計: 約 7.17
	
	return TestRunner.assert_true(priority > 6.0 and priority < 8.0, 
		"Combined factors should produce expected priority range")

func test_priority_weights_configurable():
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# 重みパラメータが存在することを確認
	if not "adjacency_weight" in grid_manager:
		return TestRunner.assert_true(false, "GridManager should have adjacency_weight property")
	if not "density_weight" in grid_manager:
		return TestRunner.assert_true(false, "GridManager should have density_weight property")
	if not "distance_weight" in grid_manager:
		return TestRunner.assert_true(false, "GridManager should have distance_weight property")
	
	# デフォルト値の確認
	if not TestRunner.assert_equal(grid_manager.adjacency_weight, 10.0, 
		"Default adjacency_weight should be 10.0"):
		return false
	if not TestRunner.assert_equal(grid_manager.density_weight, 2.0, 
		"Default density_weight should be 2.0"):
		return false
	return TestRunner.assert_equal(grid_manager.distance_weight, 0.5, 
		"Default distance_weight should be 0.5")