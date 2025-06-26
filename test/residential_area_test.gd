extends Node

# GridManagerの円形住宅エリア機能のテスト

func test_center_position_setting():
	# GridManagerスクリプトを直接ロードしてインスタンス化
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# デフォルトの中心点確認
	if not TestRunner.assert_equal(grid_manager.center_position, Vector2i(25, 25), 
		"Default center should be (25, 25)"):
		return false
	
	# 半径の確認
	if not TestRunner.assert_equal(grid_manager.residential_radius, 5.0,
		"Default residential radius should be 5.0"):
		return false
		
	return TestRunner.assert_equal(grid_manager.max_radius, 20.0,
		"Default max radius should be 20.0")

func test_within_residential_area():
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# 中心点は必ずエリア内
	if not TestRunner.assert_true(
		grid_manager.is_within_residential_area(Vector2i(25, 25)),
		"Center position should be within residential area"):
		return false
	
	# 中心から半径内の点
	if not TestRunner.assert_true(
		grid_manager.is_within_residential_area(Vector2i(28, 25)),
		"Position 3 units from center on X axis should be within area"):
		return false
	
	if not TestRunner.assert_true(
		grid_manager.is_within_residential_area(Vector2i(25, 29)),
		"Position 4 units from center on Y axis should be within area"):
		return false
	
	# 斜め方向（距離約3.5）
	return TestRunner.assert_true(
		grid_manager.is_within_residential_area(Vector2i(27, 28)),
		"Position at diagonal distance ~3.5 should be within area")

func test_outside_residential_area():
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# 明らかにエリア外の点
	if not TestRunner.assert_false(
		grid_manager.is_within_residential_area(Vector2i(35, 25)),
		"Position 10 units from center should be outside area"):
		return false
	
	if not TestRunner.assert_false(
		grid_manager.is_within_residential_area(Vector2i(25, 35)),
		"Position 10 units from center should be outside area"):
		return false
	
	# 半径をギリギリ超える点
	return TestRunner.assert_false(
		grid_manager.is_within_residential_area(Vector2i(31, 25)),
		"Position 6 units from center should be outside area (radius 5)")

func test_boundary_cases():
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# グリッドの端
	if not TestRunner.assert_false(
		grid_manager.is_within_residential_area(Vector2i(0, 0)),
		"Grid corner (0,0) should be outside residential area"):
		return false
	
	if not TestRunner.assert_false(
		grid_manager.is_within_residential_area(Vector2i(49, 49)),
		"Grid corner (49,49) should be outside residential area"):
		return false
	
	# 半径を変更した場合のテスト
	grid_manager.residential_radius = 10.0
	if not TestRunner.assert_true(
		grid_manager.is_within_residential_area(Vector2i(31, 25)),
		"Position 6 units from center should be within area after radius increase to 10"):
		return false
	
	# 半径をmax_radiusに設定
	grid_manager.residential_radius = grid_manager.max_radius
	return TestRunner.assert_true(
		grid_manager.is_within_residential_area(Vector2i(25, 45)),
		"Position 20 units from center should be within area when radius = max_radius")
