extends Node

# GridManagerの道路機能のテスト

func test_grid_cell_types():
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# 初期状態はEMPTY
	if not TestRunner.assert_equal(grid_manager.get_cell_type(10, 10), grid_manager.CellType.EMPTY,
		"Initial cell should be EMPTY"):
		return false
	
	# 家を配置
	grid_manager.occupy_position(10, 10)
	if not TestRunner.assert_equal(grid_manager.get_cell_type(10, 10), grid_manager.CellType.HOUSE,
		"Cell with house should be HOUSE"):
		return false
	
	# 道路を配置
	grid_manager.occupy_road(11, 10)
	return TestRunner.assert_equal(grid_manager.get_cell_type(11, 10), grid_manager.CellType.ROAD,
		"Cell with road should be ROAD")

func test_road_placement_validation():
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# 空き地には道路を配置可能
	if not TestRunner.assert_true(grid_manager.is_valid_road_position(10, 10),
		"Empty cell should be valid for road"):
		return false
	
	# 家の上には道路を配置不可
	grid_manager.occupy_position(10, 10)
	if not TestRunner.assert_false(grid_manager.is_valid_road_position(10, 10),
		"Cell with house should not be valid for road"):
		return false
	
	# 道路の上には道路を配置可能（交差点）
	grid_manager.occupy_road(11, 10)
	return TestRunner.assert_true(grid_manager.is_valid_road_position(11, 10),
		"Cell with road should be valid for another road (intersection)")

func test_road_occupation():
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# 道路を配置
	grid_manager.occupy_road(15, 15)
	
	# is_occupiedは道路でもtrueを返すべき
	if not TestRunner.assert_true(grid_manager.is_occupied(15, 15),
		"Road should count as occupied"):
		return false
	
	# get_cell_typeで道路タイプを確認
	return TestRunner.assert_equal(grid_manager.get_cell_type(15, 15), grid_manager.CellType.ROAD,
		"Occupied road should return ROAD type")

func test_grid_boundaries_with_road():
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# グリッド外への道路配置は無効
	if not TestRunner.assert_false(grid_manager.is_valid_road_position(-1, 10),
		"Out of bounds should not be valid for road"):
		return false
	
	if not TestRunner.assert_false(grid_manager.is_valid_road_position(10, 50),
		"Out of bounds should not be valid for road"):
		return false
	
	# グリッド内は有効
	return TestRunner.assert_true(grid_manager.is_valid_road_position(0, 0),
		"Grid corner should be valid for road")

func test_mixed_occupation():
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# 家、道路、空きが混在するパターン
	grid_manager.occupy_position(10, 10)  # 家
	grid_manager.occupy_road(10, 11)      # 道路
	# (10, 12)は空き
	
	if not TestRunner.assert_equal(grid_manager.get_cell_type(10, 10), grid_manager.CellType.HOUSE,
		"Should be HOUSE"):
		return false
	
	if not TestRunner.assert_equal(grid_manager.get_cell_type(10, 11), grid_manager.CellType.ROAD,
		"Should be ROAD"):
		return false
	
	return TestRunner.assert_equal(grid_manager.get_cell_type(10, 12), grid_manager.CellType.EMPTY,
		"Should be EMPTY")