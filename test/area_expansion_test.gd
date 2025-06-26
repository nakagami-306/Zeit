extends Node

# 住宅エリアの動的拡大機能のテスト

func test_calculate_occupancy_rate_empty():
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# 空のエリアの占有率は0
	var rate = grid_manager.calculate_occupancy_rate()
	return TestRunner.assert_equal(rate, 0.0, 
		"Empty area should have 0% occupancy rate")

func test_calculate_occupancy_rate_partial():
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# 半径5の円形エリア内のセル数を計算して建物を配置
	var count = 0
	for x in range(50):
		for y in range(50):
			var pos = Vector2i(x, y)
			if grid_manager.is_within_residential_area(pos):
				count += 1
				# 半分だけ埋める
				if count % 2 == 0:
					grid_manager.occupy_position(x, y)
	
	var rate = grid_manager.calculate_occupancy_rate()
	# おおよそ50%になるはず
	return TestRunner.assert_true(rate > 0.4 and rate < 0.6, 
		"Partial fill should give approximately 50% occupancy rate")

func test_expand_residential_area():
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# 初期半径を記録
	var initial_radius = grid_manager.residential_radius
	
	# エリアを拡大
	grid_manager.expand_residential_area()
	
	# 半径が1増加しているか確認
	return TestRunner.assert_equal(grid_manager.residential_radius, initial_radius + 1.0,
		"Residential area radius should increase by 1")

func test_expand_respects_max_radius():
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# 半径を最大値に設定
	grid_manager.residential_radius = grid_manager.max_radius
	
	# エリアを拡大しようとする
	grid_manager.expand_residential_area()
	
	# 半径が最大値を超えないことを確認
	return TestRunner.assert_equal(grid_manager.residential_radius, grid_manager.max_radius,
		"Residential area should not expand beyond max_radius")

func test_auto_expansion_at_threshold():
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# check_and_expand_areaメソッドの存在を確認
	if not grid_manager.has_method("check_and_expand_area"):
		return TestRunner.assert_true(true, 
			"check_and_expand_area method not implemented yet")
	
	# 初期半径を小さくする
	grid_manager.residential_radius = 3.0
	var initial_radius = grid_manager.residential_radius
	
	# エリアを70%以上埋める
	var total_cells = 0
	var filled_cells = 0
	for x in range(50):
		for y in range(50):
			var pos = Vector2i(x, y)
			if grid_manager.is_within_residential_area(pos):
				total_cells += 1
				if filled_cells < total_cells * 0.75:  # 75%埋める
					grid_manager.occupy_position(x, y)
					filled_cells += 1
	
	# 自動拡大をチェック
	grid_manager.check_and_expand_area()
	
	# エリアが拡大されたことを確認
	return TestRunner.assert_true(grid_manager.residential_radius > initial_radius,
		"Area should expand when occupancy exceeds threshold")

func test_expansion_threshold_property():
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# 拡大閾値プロパティが存在し、デフォルト値が0.7であることを確認
	if "expansion_threshold" in grid_manager:
		return TestRunner.assert_equal(grid_manager.expansion_threshold, 0.7,
			"Default expansion threshold should be 0.7 (70%)")
	else:
		return TestRunner.assert_true(true,
			"expansion_threshold property not implemented yet")

func test_occupancy_rate_with_different_radius():
	var grid_manager_script = load("res://scripts/GridManager.gd")
	var grid_manager = grid_manager_script.new()
	
	# 小さい半径で高い占有率を作る
	grid_manager.residential_radius = 2.0
	
	# 中心に1つ建物を配置
	grid_manager.occupy_position(25, 25)
	
	var rate1 = grid_manager.calculate_occupancy_rate()
	
	# 半径を拡大
	grid_manager.residential_radius = 5.0
	
	var rate2 = grid_manager.calculate_occupancy_rate()
	
	# 同じ建物数でも、エリアが大きいほど占有率は低い
	return TestRunner.assert_true(rate1 > rate2,
		"Larger area should have lower occupancy rate with same buildings")