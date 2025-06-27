extends Node

# 支線道路生成のテスト

func test_branch_roads_generation():
	var road_manager_script = load("res://scripts/RoadManager.gd")
	var road_manager = road_manager_script.new()
	
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# 主要道路を配置
	for i in range(10, 20):
		grid_manager.occupy_road(i, 15)
	
	# 道路から離れた場所に家を配置
	grid_manager.occupy_position(15, 10)
	grid_manager.occupy_position(15, 20)
	
	road_manager.grid_manager = grid_manager
	
	# 支線道路を生成
	var branches_created = road_manager.generate_branch_roads()
	
	return TestRunner.assert_true(branches_created > 0, "Branch roads should be created to connect houses")

func test_all_houses_connected():
	var road_manager_script = load("res://scripts/RoadManager.gd")
	var road_manager = road_manager_script.new()
	
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# 主要道路
	for i in range(20, 30):
		grid_manager.occupy_road(i, 25)
	
	# 複数の家を配置
	var house_positions = [
		Vector2i(25, 20),
		Vector2i(25, 30),
		Vector2i(22, 25),
		Vector2i(28, 25)
	]
	
	for pos in house_positions:
		grid_manager.occupy_position(pos.x, pos.y)
	
	road_manager.grid_manager = grid_manager
	
	# 支線道路を生成
	road_manager.generate_branch_roads()
	
	# すべての家が道路に接続されているか確認
	var all_connected = true
	for house_pos in house_positions:
		if not road_manager.is_house_connected_to_road(house_pos):
			all_connected = false
			break
	
	return TestRunner.assert_true(all_connected, "All houses should be connected to roads")

func test_find_nearest_road():
	var road_manager_script = load("res://scripts/RoadManager.gd")
	var road_manager = road_manager_script.new()
	
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# 道路を配置
	grid_manager.occupy_road(10, 10)
	grid_manager.occupy_road(20, 20)
	
	road_manager.grid_manager = grid_manager
	
	# (15, 15)から最寄りの道路を探す
	var nearest = road_manager.find_nearest_road(Vector2i(15, 15))
	
	if not TestRunner.assert_not_null(nearest, "Should find nearest road"):
		return false
	
	# どちらかの道路が返されるはず（等距離）
	var is_valid = nearest == Vector2i(10, 10) or nearest == Vector2i(20, 20)
	return TestRunner.assert_true(is_valid, "Should return one of the roads")

func test_connect_house_to_road():
	var road_manager_script = load("res://scripts/RoadManager.gd")
	var road_manager = road_manager_script.new()
	
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# 道路を配置
	for i in range(10, 20):
		grid_manager.occupy_road(i, 15)
	
	# 家を配置
	var house_pos = Vector2i(15, 10)
	grid_manager.occupy_position(house_pos.x, house_pos.y)
	
	road_manager.grid_manager = grid_manager
	
	# 家を道路に接続
	var connected = road_manager.connect_house_to_road(house_pos)
	
	if not TestRunner.assert_true(connected, "House should be connected to road"):
		return false
	
	# 接続パスが作成されたか確認
	var has_connecting_road = false
	# 垂直方向の道路をチェック
	for y in range(11, 15):
		if grid_manager.get_cell_type(15, y) == grid_manager.CellType.ROAD:
			has_connecting_road = true
			break
	
	return TestRunner.assert_true(has_connecting_road, "Connecting road should be created")

func test_shortest_connection():
	var road_manager_script = load("res://scripts/RoadManager.gd")
	var road_manager = road_manager_script.new()
	
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# 複数の道路を配置
	grid_manager.occupy_road(10, 10)  # 近い
	grid_manager.occupy_road(30, 30)  # 遠い
	
	# 家を配置
	var house_pos = Vector2i(12, 12)
	grid_manager.occupy_position(house_pos.x, house_pos.y)
	
	road_manager.grid_manager = grid_manager
	
	# 家を最寄りの道路に接続
	road_manager.connect_house_to_road(house_pos)
	
	# 近い方の道路に接続されているか確認
	var connected_to_near = false
	# (12,12)から(10,10)への経路上に道路があるか
	if grid_manager.get_cell_type(11, 12) == grid_manager.CellType.ROAD or \
	   grid_manager.get_cell_type(12, 11) == grid_manager.CellType.ROAD:
		connected_to_near = true
	
	return TestRunner.assert_true(connected_to_near, "Should connect to nearest road")