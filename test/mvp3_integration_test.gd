extends Node

# MVP-3の完全な統合テスト

func test_complete_road_system():
	var game_manager = get_node("/root/GameManager")
	var grid_manager = game_manager.get_node("GridManager")
	var road_manager = game_manager.get_node("RoadManager")
	
	# グリッドをリセット
	grid_manager.occupied_positions.clear()
	grid_manager.cell_types.clear()
	game_manager.house_count = 0
	game_manager.houses = 0
	
	# 10軒の家を生成
	for i in range(10):
		game_manager._spawn_house()
		game_manager.house_count += 1
		game_manager.houses = game_manager.house_count
	
	# 道路が生成されたか確認
	var road_count = 0
	var house_count = 0
	
	for x in range(grid_manager.grid_size.x):
		for y in range(grid_manager.grid_size.y):
			var cell_type = grid_manager.get_cell_type(x, y)
			if cell_type == grid_manager.CellType.ROAD:
				road_count += 1
			elif cell_type == grid_manager.CellType.HOUSE:
				house_count += 1
	
	if not TestRunner.assert_equal(house_count, 10, "Should have 10 houses"):
		return false
	
	return TestRunner.assert_true(road_count > 0, "Should have roads connecting houses")

func test_organic_road_pattern():
	var game_manager = get_node("/root/GameManager")
	var grid_manager = game_manager.get_node("GridManager")
	
	# グリッドをリセット
	grid_manager.occupied_positions.clear()
	grid_manager.cell_types.clear()
	game_manager.house_count = 0
	
	# 複数のクラスターを作成
	# クラスター1
	grid_manager.occupy_position(10, 10)
	grid_manager.occupy_position(11, 10)
	grid_manager.occupy_position(10, 11)
	
	# クラスター2
	grid_manager.occupy_position(20, 20)
	grid_manager.occupy_position(21, 20)
	grid_manager.occupy_position(20, 21)
	
	game_manager.house_count = 6
	
	# 道路生成
	game_manager._check_and_generate_roads()
	
	# クラスター間に道路があるか確認
	var has_connecting_road = false
	for x in range(12, 20):
		for y in range(12, 20):
			if grid_manager.get_cell_type(x, y) == grid_manager.CellType.ROAD:
				has_connecting_road = true
				break
		if has_connecting_road:
			break
	
	return TestRunner.assert_true(has_connecting_road, "Should have roads connecting clusters")

func test_performance_with_roads():
	var game_manager = get_node("/root/GameManager")
	var grid_manager = game_manager.get_node("GridManager")
	
	# グリッドをリセット
	grid_manager.occupied_positions.clear()
	grid_manager.cell_types.clear()
	
	# パフォーマンステスト用に半径を広げる
	grid_manager.residential_radius = 15.0
	
	var start_time = Time.get_ticks_msec()
	
	# 50軒の家を配置
	for i in range(50):
		var pos = grid_manager.get_best_position()
		if pos != Vector2i(-1, -1):
			grid_manager.occupy_position(pos.x, pos.y)
	
	game_manager.house_count = 50
	
	# 道路生成
	game_manager._check_and_generate_roads()
	
	var elapsed = Time.get_ticks_msec() - start_time
	
	# 2秒以内に完了することを確認
	return TestRunner.assert_true(elapsed < 2000, 
		"Road generation for 50 houses should complete within 2 seconds")

func test_visual_road_instances():
	var game_manager = get_node("/root/GameManager")
	var grid_manager = game_manager.get_node("GridManager")
	var road_container = game_manager.get_node("RoadContainer")
	
	# 道路を配置
	grid_manager.occupy_road(25, 25)
	grid_manager.occupy_road(26, 25)
	grid_manager.occupy_road(27, 25)
	
	# 道路インスタンスを生成
	game_manager._spawn_road_instances()
	
	# RoadContainerに道路インスタンスが作成されたか確認
	return TestRunner.assert_equal(road_container.get_child_count(), 3,
		"Should have 3 road instances in RoadContainer")

func test_roads_respect_residential_area():
	var game_manager = get_node("/root/GameManager")
	var grid_manager = game_manager.get_node("GridManager")
	
	# グリッドをリセット
	grid_manager.occupied_positions.clear()
	grid_manager.cell_types.clear()
	
	# 住宅エリアの境界に家を配置
	var radius = int(grid_manager.residential_radius)
	grid_manager.occupy_position(25 + radius, 25)
	grid_manager.occupy_position(25 - radius, 25)
	grid_manager.occupy_position(25, 25 + radius)
	grid_manager.occupy_position(25, 25 - radius)
	
	game_manager.house_count = 4
	
	# 道路生成
	game_manager._check_and_generate_roads()
	
	# 住宅エリア外に道路がないことを確認
	var roads_outside = false
	for x in range(grid_manager.grid_size.x):
		for y in range(grid_manager.grid_size.y):
			if grid_manager.get_cell_type(x, y) == grid_manager.CellType.ROAD:
				if not grid_manager.is_within_residential_area(Vector2i(x, y)):
					roads_outside = true
					break
		if roads_outside:
			break
	
	return TestRunner.assert_false(roads_outside, 
		"Roads should only be placed within residential area")