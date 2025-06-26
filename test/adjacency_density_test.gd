extends Node

# GridManagerの隣接・密度計算機能のテスト

func test_adjacent_buildings_count_empty():
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# 空のグリッドでは隣接建物は0
	var count = grid_manager.get_adjacent_buildings_count(Vector2i(10, 10))
	return TestRunner.assert_equal(count, 0, 
		"Empty grid should have 0 adjacent buildings")

func test_adjacent_buildings_count_one():
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# 建物を配置
	grid_manager.occupy_position(10, 10)
	
	# 隣接1つ
	var count = grid_manager.get_adjacent_buildings_count(Vector2i(10, 11))
	if not TestRunner.assert_equal(count, 1, 
		"Should have 1 adjacent building to the south"):
		return false
	
	# 別の隣接位置でも確認
	count = grid_manager.get_adjacent_buildings_count(Vector2i(11, 10))
	return TestRunner.assert_equal(count, 1, 
		"Should have 1 adjacent building to the west")

func test_adjacent_buildings_count_multiple():
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# 十字型に建物を配置
	grid_manager.occupy_position(10, 9)   # 北
	grid_manager.occupy_position(11, 10)  # 東
	grid_manager.occupy_position(10, 11)  # 南
	grid_manager.occupy_position(9, 10)   # 西
	
	# 中心位置での隣接数は4
	var count = grid_manager.get_adjacent_buildings_count(Vector2i(10, 10))
	return TestRunner.assert_equal(count, 4, 
		"Center position should have 4 adjacent buildings")

func test_adjacent_buildings_count_diagonal_not_counted():
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# 斜め位置に建物を配置
	grid_manager.occupy_position(9, 9)    # 北西
	grid_manager.occupy_position(11, 9)   # 北東
	grid_manager.occupy_position(9, 11)   # 南西
	grid_manager.occupy_position(11, 11)  # 南東
	
	# 斜めの建物は隣接としてカウントされない
	var count = grid_manager.get_adjacent_buildings_count(Vector2i(10, 10))
	return TestRunner.assert_equal(count, 0, 
		"Diagonal buildings should not be counted as adjacent")

func test_area_density_empty():
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# 空のエリアの密度は0
	var density = grid_manager.get_area_density(Vector2i(10, 10), 1)
	return TestRunner.assert_equal(density, 0.0, 
		"Empty area should have 0 density")

func test_area_density_with_buildings():
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# 3x3エリアに建物を配置
	grid_manager.occupy_position(10, 10)
	grid_manager.occupy_position(10, 11)
	grid_manager.occupy_position(11, 10)
	
	# 半径1（3x3エリア）の密度計算
	# 3建物 / 9マス = 0.333...
	var density = grid_manager.get_area_density(Vector2i(10, 10), 1)
	if not TestRunner.assert_true(density > 0.3 and density < 0.4, 
		"Density should be approximately 0.33 (3/9)"):
		return false
	
	# 半径2（5x5エリア）の密度計算
	# 3建物 / 25マス = 0.12
	density = grid_manager.get_area_density(Vector2i(10, 10), 2)
	return TestRunner.assert_true(density > 0.1 and density < 0.15, 
		"Density with radius 2 should be approximately 0.12 (3/25)")

func test_area_density_edge_cases():
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# グリッドの端での密度計算
	grid_manager.occupy_position(0, 0)
	grid_manager.occupy_position(0, 1)
	
	# 端では計算可能なエリアのみを考慮
	var density = grid_manager.get_area_density(Vector2i(0, 0), 1)
	# 0,0を中心とした場合、実際のエリアは2x2（右下のみ）
	# 2建物 / 4マス = 0.5
	return TestRunner.assert_true(density >= 0.4, 
		"Edge density calculation should only consider valid grid positions")