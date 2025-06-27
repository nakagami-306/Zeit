extends Node

# 主要道路生成のテスト

func test_main_roads_generation():
	var road_manager_script = load("res://scripts/RoadManager.gd")
	var road_manager = road_manager_script.new()
	
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# ホットスポットを作るため家を配置
	# クラスター1
	for i in range(3):
		for j in range(3):
			grid_manager.occupy_position(10 + i, 10 + j)
	
	# クラスター2
	for i in range(2):
		for j in range(2):
			grid_manager.occupy_position(20 + i, 20 + j)
	
	road_manager.grid_manager = grid_manager
	
	# 主要道路を生成
	var roads_placed = road_manager.generate_main_roads()
	
	# 道路が生成されたことを確認
	return TestRunner.assert_true(roads_placed > 0, "Main roads should be generated between hotspots")

func test_minimum_houses_requirement():
	var road_manager_script = load("res://scripts/RoadManager.gd")
	var road_manager = road_manager_script.new()
	
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	road_manager.grid_manager = grid_manager
	road_manager.min_houses_for_roads = 5
	
	# 4軒の家（最小値未満）
	for i in range(4):
		grid_manager.occupy_position(10 + i, 10)
	
	var roads_placed = road_manager.generate_main_roads()
	
	if not TestRunner.assert_equal(roads_placed, 0, "No roads should be generated with less than minimum houses"):
		return false
	
	# 5軒目を追加
	grid_manager.occupy_position(14, 10)
	
	roads_placed = road_manager.generate_main_roads()
	
	return TestRunner.assert_true(roads_placed > 0, "Roads should be generated when minimum houses reached")

func test_hotspot_connection():
	var road_manager_script = load("res://scripts/RoadManager.gd")
	var road_manager = road_manager_script.new()
	
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# 2つの明確なホットスポット
	grid_manager.occupy_position(10, 10)
	grid_manager.occupy_position(11, 10)
	grid_manager.occupy_position(10, 11)
	
	grid_manager.occupy_position(20, 20)
	grid_manager.occupy_position(21, 20)
	grid_manager.occupy_position(20, 21)
	
	road_manager.grid_manager = grid_manager
	
	# ホットスポット間を接続
	var connected = road_manager.connect_hotspots(Vector2i(10, 10), Vector2i(20, 20))
	
	if not TestRunner.assert_true(connected, "Hotspots should be connected"):
		return false
	
	# 道路が実際に配置されたか確認
	var has_road = false
	for x in range(10, 21):
		for y in range(10, 21):
			if grid_manager.get_cell_type(x, y) == grid_manager.CellType.ROAD:
				has_road = true
				break
		if has_road:
			break
	
	return TestRunner.assert_true(has_road, "Road cells should be placed between hotspots")

func test_road_intersection_allowed():
	var road_manager_script = load("res://scripts/RoadManager.gd")
	var road_manager = road_manager_script.new()
	
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	road_manager.grid_manager = grid_manager
	
	# 既存の道路を配置
	grid_manager.occupy_road(15, 10)
	grid_manager.occupy_road(15, 11)
	grid_manager.occupy_road(15, 12)
	
	# 交差する道路セグメントを配置
	var result = road_manager.place_road_segment([
		Vector2i(14, 11),
		Vector2i(15, 11),  # 交差点
		Vector2i(16, 11)
	])
	
	# 交差が許可されることを確認
	return TestRunner.assert_true(result, "Road intersections should be allowed")

func test_place_road_segment():
	var road_manager_script = load("res://scripts/RoadManager.gd")
	var road_manager = road_manager_script.new()
	
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	road_manager.grid_manager = grid_manager
	
	# 道路セグメントを配置
	var segment = [Vector2i(10, 10), Vector2i(11, 10), Vector2i(12, 10)]
	var placed = road_manager.place_road_segment(segment)
	
	if not TestRunner.assert_true(placed, "Road segment should be placed"):
		return false
	
	# 各セルが道路になっているか確認
	for point in segment:
		if not TestRunner.assert_equal(
			grid_manager.get_cell_type(point.x, point.y), 
			grid_manager.CellType.ROAD,
			"Each point in segment should be ROAD"):
			return false
	
	return true