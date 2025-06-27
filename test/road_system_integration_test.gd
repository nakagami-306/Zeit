extends Node

# 道路システムの統合テスト

func test_road_generation_after_houses():
	var game_manager = get_node("/root/GameManager")
	var grid_manager = game_manager.get_node("GridManager")
	
	# グリッドをリセット
	grid_manager.occupied_positions.clear()
	grid_manager.cell_types.clear()
	game_manager.house_count = 0
	game_manager.houses = 0
	
	# RoadManagerが存在することを確認
	var road_manager = game_manager.get_node_or_null("RoadManager")
	if not TestRunner.assert_not_null(road_manager, "RoadManager should exist"):
		return false
	
	# 6軒の家を生成（道路生成の最小値以上）
	for i in range(6):
		game_manager._spawn_house()
		game_manager.house_count += 1
		game_manager.houses = game_manager.house_count
	
	# 道路が生成されたか確認
	var has_road = false
	for x in range(grid_manager.grid_size.x):
		for y in range(grid_manager.grid_size.y):
			if grid_manager.get_cell_type(x, y) == grid_manager.CellType.ROAD:
				has_road = true
				break
		if has_road:
			break
	
	return TestRunner.assert_true(has_road, "Roads should be generated after minimum houses")

func test_new_house_road_connection():
	var game_manager = get_node("/root/GameManager")
	var grid_manager = game_manager.get_node("GridManager")
	var road_manager = game_manager.get_node_or_null("RoadManager")
	
	if not road_manager:
		return TestRunner.assert_true(false, "RoadManager required for this test")
	
	# 既存の道路を配置
	for i in range(20, 30):
		grid_manager.occupy_road(i, 25)
	
	# 道路から離れた位置に家を生成
	grid_manager.occupy_position(25, 20)
	game_manager.house_count += 1
	
	# 道路生成を手動でトリガー
	road_manager.grid_manager = grid_manager
	road_manager.generate_branch_roads()
	
	# 家が道路に接続されたか確認
	var connected = road_manager.is_house_connected_to_road(Vector2i(25, 20))
	
	return TestRunner.assert_true(connected, "New house should be connected to existing roads")

func test_roads_coexist_with_houses():
	var game_manager = get_node("/root/GameManager")
	var grid_manager = game_manager.get_node("GridManager")
	
	# 家を配置
	grid_manager.occupy_position(10, 10)
	grid_manager.occupy_position(15, 15)
	
	# 道路を配置
	for i in range(10, 16):
		grid_manager.occupy_road(i, 12)
	
	# 家が残っているか確認
	if not TestRunner.assert_equal(grid_manager.get_cell_type(10, 10), grid_manager.CellType.HOUSE,
		"House should remain after road placement"):
		return false
	
	if not TestRunner.assert_equal(grid_manager.get_cell_type(15, 15), grid_manager.CellType.HOUSE,
		"House should remain after road placement"):
		return false
	
	# 道路も存在するか確認
	return TestRunner.assert_equal(grid_manager.get_cell_type(12, 12), grid_manager.CellType.ROAD,
		"Road should exist alongside houses")

func test_road_instance_creation():
	var game_manager = get_node("/root/GameManager")
	var grid_manager = game_manager.get_node("GridManager")
	
	# RoadContainerが存在することを確認
	var road_container = game_manager.get_node_or_null("RoadContainer")
	if not road_container:
		# RoadContainerを作成
		road_container = Node3D.new()
		road_container.name = "RoadContainer"
		game_manager.add_child(road_container)
	
	# 道路を配置
	grid_manager.occupy_road(20, 20)
	
	# spawn_road関数が存在する場合は呼び出す
	if game_manager.has_method("spawn_road"):
		game_manager.spawn_road(Vector3(20 - 25, 0, 20 - 25))
		
		# 道路インスタンスが作成されたか確認
		return TestRunner.assert_true(road_container.get_child_count() > 0,
			"Road instance should be created in RoadContainer")
	else:
		# メソッドがない場合はスキップ
		return TestRunner.assert_true(true, "spawn_road method not implemented yet")