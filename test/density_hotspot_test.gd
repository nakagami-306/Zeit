extends Node

# 密度計算とホットスポット検出のテスト

func test_density_map_generation():
	var road_manager_script = load("res://scripts/RoadManager.gd")
	var road_manager = road_manager_script.new()
	
	# GridManagerのモックを作成
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# いくつか家を配置
	grid_manager.occupy_position(25, 25)
	grid_manager.occupy_position(26, 25)
	grid_manager.occupy_position(25, 26)
	
	road_manager.grid_manager = grid_manager
	
	# 密度マップを生成
	var density_map = road_manager.calculate_density_map()
	
	# 密度マップが正しいサイズであることを確認
	if not TestRunner.assert_not_null(density_map, "Density map should be generated"):
		return false
	
	# 家の周辺の密度が高いことを確認
	var center_density = road_manager.get_density_at(25, 25, density_map)
	return TestRunner.assert_true(center_density > 0, "Density around houses should be positive")

func test_hotspot_detection():
	var road_manager_script = load("res://scripts/RoadManager.gd")
	var road_manager = road_manager_script.new()
	
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# クラスターを作成
	# クラスター1（高密度）
	grid_manager.occupy_position(10, 10)
	grid_manager.occupy_position(11, 10)
	grid_manager.occupy_position(10, 11)
	grid_manager.occupy_position(11, 11)
	
	# クラスター2（中密度）
	grid_manager.occupy_position(30, 30)
	grid_manager.occupy_position(31, 30)
	
	road_manager.grid_manager = grid_manager
	
	# ホットスポットを検出
	var hotspots = road_manager.find_hotspots()
	
	if not TestRunner.assert_true(hotspots.size() >= 2, "Should detect at least 2 hotspots"):
		return false
	
	# 最初のホットスポットがクラスター1付近にあることを確認
	var first_hotspot = hotspots[0]
	var distance_to_cluster1 = first_hotspot.position.distance_to(Vector2i(10, 10))
	return TestRunner.assert_true(distance_to_cluster1 <= 2, "First hotspot should be near cluster 1")

func test_top_hotspots_selection():
	var road_manager_script = load("res://scripts/RoadManager.gd")
	var road_manager = road_manager_script.new()
	
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# 複数のクラスターを作成
	for i in range(5):
		var base_x = i * 8 + 5
		var base_y = i * 8 + 5
		for j in range(i + 1):  # クラスターサイズを変える
			grid_manager.occupy_position(base_x, base_y + j)
	
	road_manager.grid_manager = grid_manager
	
	# 上位3つのホットスポットを取得
	var top_hotspots = road_manager.get_top_hotspots(3)
	
	if not TestRunner.assert_equal(top_hotspots.size(), 3, "Should return exactly 3 hotspots"):
		return false
	
	# 密度が降順になっていることを確認
	var densities_ok = true
	for i in range(1, top_hotspots.size()):
		if top_hotspots[i].density > top_hotspots[i-1].density:
			densities_ok = false
			break
	
	return TestRunner.assert_true(densities_ok, "Hotspots should be sorted by density (descending)")

func test_empty_grid_density():
	var road_manager_script = load("res://scripts/RoadManager.gd")
	var road_manager = road_manager_script.new()
	
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	road_manager.grid_manager = grid_manager
	
	# 空のグリッドでの密度計算
	var density_map = road_manager.calculate_density_map()
	
	# すべての密度が0であることを確認
	var all_zero = true
	for x in range(50):
		for y in range(50):
			if road_manager.get_density_at(x, y, density_map) != 0:
				all_zero = false
				break
		if not all_zero:
			break
	
	return TestRunner.assert_true(all_zero, "Empty grid should have zero density everywhere")

func test_density_calculation_radius():
	var road_manager_script = load("res://scripts/RoadManager.gd")
	var road_manager = road_manager_script.new()
	
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# 中心に1つ家を配置
	grid_manager.occupy_position(25, 25)
	
	road_manager.grid_manager = grid_manager
	road_manager.density_radius = 3  # 半径3で計算
	
	var density_map = road_manager.calculate_density_map()
	
	# 半径3以内は密度が正
	var density_at_2 = road_manager.get_density_at(27, 25, density_map)  # 距離2
	if not TestRunner.assert_true(density_at_2 > 0, "Density within radius should be positive"):
		return false
	
	# 半径3より外は密度が0
	var density_at_4 = road_manager.get_density_at(29, 25, density_map)  # 距離4
	return TestRunner.assert_equal(density_at_4, 0.0, "Density outside radius should be zero")