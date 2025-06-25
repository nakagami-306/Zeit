extends Node

# グリッドシステムのテスト

func test_grid_size_is_50x50():
	var game_manager = get_node("/root/GameManager")
	if not game_manager:
		return false
	
	# GridManagerが存在することを確認
	var grid_manager = game_manager.get_node_or_null("GridManager")
	if not TestRunner.assert_not_null(grid_manager, "GridManager should exist in GameManager"):
		return false
	
	# グリッドサイズが50x50であることを確認
	if not "grid_size" in grid_manager:
		return TestRunner.assert_true(false, "GridManager should have grid_size property")
	
	return TestRunner.assert_equal(grid_manager.grid_size, Vector2i(50, 50), 
		"Grid size should be 50x50")

func test_grid_position_validation():
	var game_manager = get_node("/root/GameManager")
	if not game_manager:
		return false
	
	var grid_manager = game_manager.get_node_or_null("GridManager")
	if not grid_manager:
		return false
	
	# is_valid_positionメソッドが存在することを確認
	if not TestRunner.assert_true(grid_manager.has_method("is_valid_position"), 
		"GridManager should have is_valid_position method"):
		return false
	
	# 有効な位置のテスト
	var valid_positions = [
		Vector2i(0, 0),
		Vector2i(25, 25),
		Vector2i(49, 49),
		Vector2i(10, 40),
	]
	
	for pos in valid_positions:
		if not TestRunner.assert_true(grid_manager.is_valid_position(pos.x, pos.y), 
			"Position " + str(pos) + " should be valid"):
			return false
	
	# 無効な位置のテスト
	var invalid_positions = [
		Vector2i(-1, 0),
		Vector2i(0, -1),
		Vector2i(50, 0),
		Vector2i(0, 50),
		Vector2i(100, 100),
	]
	
	for pos in invalid_positions:
		if not TestRunner.assert_false(grid_manager.is_valid_position(pos.x, pos.y), 
			"Position " + str(pos) + " should be invalid"):
			return false
	
	return true

func test_grid_occupation_check():
	var game_manager = get_node("/root/GameManager")
	if not game_manager:
		return false
	
	var grid_manager = game_manager.get_node_or_null("GridManager")
	if not grid_manager:
		return false
	
	# is_occupiedメソッドが存在することを確認
	if not TestRunner.assert_true(grid_manager.has_method("is_occupied"), 
		"GridManager should have is_occupied method"):
		return false
	
	# occupy_positionメソッドが存在することを確認
	if not TestRunner.assert_true(grid_manager.has_method("occupy_position"), 
		"GridManager should have occupy_position method"):
		return false
	
	# 初期状態では位置が空いていることを確認
	if not TestRunner.assert_false(grid_manager.is_occupied(10, 10), 
		"Position (10, 10) should be empty initially"):
		return false
	
	# 位置を占有
	grid_manager.occupy_position(10, 10)
	
	# 占有後は位置が占有されていることを確認
	return TestRunner.assert_true(grid_manager.is_occupied(10, 10), 
		"Position (10, 10) should be occupied after occupy_position")