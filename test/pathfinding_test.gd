extends Node

# 経路探索のテスト

func test_simple_path_finding():
	var road_manager_script = load("res://scripts/RoadManager.gd")
	var road_manager = road_manager_script.new()
	
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	road_manager.grid_manager = grid_manager
	
	# 2点間の最短経路を探索
	var start = Vector2i(10, 10)
	var end = Vector2i(15, 10)
	
	var path = road_manager.find_path(start, end)
	
	if not TestRunner.assert_not_null(path, "Path should be found"):
		return false
	
	if not TestRunner.assert_true(path.size() > 0, "Path should contain points"):
		return false
	
	# パスの始点と終点が正しいことを確認
	if not TestRunner.assert_equal(path[0], start, "Path should start at start position"):
		return false
	
	return TestRunner.assert_equal(path[path.size() - 1], end, "Path should end at end position")

func test_path_avoids_obstacles():
	var road_manager_script = load("res://scripts/RoadManager.gd")
	var road_manager = road_manager_script.new()
	
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# 障害物（家）を配置
	grid_manager.occupy_position(12, 10)
	grid_manager.occupy_position(13, 10)
	
	road_manager.grid_manager = grid_manager
	
	var start = Vector2i(10, 10)
	var end = Vector2i(15, 10)
	
	var path = road_manager.find_path(start, end)
	
	if not TestRunner.assert_not_null(path, "Path should be found even with obstacles"):
		return false
	
	# パスが障害物を通らないことを確認
	var passes_through_obstacle = false
	for point in path:
		if grid_manager.get_cell_type(point.x, point.y) == grid_manager.CellType.HOUSE:
			passes_through_obstacle = true
			break
	
	return TestRunner.assert_false(passes_through_obstacle, "Path should not pass through houses")

func test_manhattan_path_generation():
	var road_manager_script = load("res://scripts/RoadManager.gd")
	var road_manager = road_manager_script.new()
	
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	road_manager.grid_manager = grid_manager
	
	# 斜めの2点間でマンハッタン距離の経路を生成
	var start = Vector2i(10, 10)
	var end = Vector2i(15, 15)
	
	var path = road_manager.generate_manhattan_path(start, end)
	
	if not TestRunner.assert_not_null(path, "Manhattan path should be generated"):
		return false
	
	# 各ステップが直角に曲がることを確認
	var all_manhattan = true
	for i in range(1, path.size()):
		var diff = path[i] - path[i-1]
		# X方向かY方向のどちらか一方のみ移動
		if not ((abs(diff.x) == 1 and diff.y == 0) or (diff.x == 0 and abs(diff.y) == 1)):
			all_manhattan = false
			break
	
	return TestRunner.assert_true(all_manhattan, "Path should follow Manhattan distance (right angles)")

func test_no_path_available():
	var road_manager_script = load("res://scripts/RoadManager.gd")
	var road_manager = road_manager_script.new()
	
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# 終点を完全に囲む
	for x in range(14, 17):
		for y in range(14, 17):
			if x != 15 or y != 15:
				grid_manager.occupy_position(x, y)
	
	road_manager.grid_manager = grid_manager
	
	var start = Vector2i(10, 10)
	var end = Vector2i(15, 15)
	
	var path = road_manager.find_path(start, end)
	
	# パスが見つからないか、空のパスであることを確認
	return TestRunner.assert_true(path == null or path.is_empty(), 
		"No path should be found when destination is blocked")

func test_path_blocked_check():
	var road_manager_script = load("res://scripts/RoadManager.gd")
	var road_manager = road_manager_script.new()
	
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	road_manager.grid_manager = grid_manager
	
	# 空のパスはブロックされていない
	var empty_path = [Vector2i(10, 10), Vector2i(11, 10)]
	if not TestRunner.assert_false(road_manager.is_path_blocked(empty_path),
		"Empty path should not be blocked"):
		return false
	
	# 家を配置
	grid_manager.occupy_position(11, 10)
	
	# 家を通るパスはブロックされている
	return TestRunner.assert_true(road_manager.is_path_blocked(empty_path),
		"Path through house should be blocked")