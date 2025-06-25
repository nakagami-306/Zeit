extends Node

# 家の配置システムのテスト

func test_house_spawns_at_random_position():
	var game_manager = get_node("/root/GameManager")
	if not game_manager:
		return false
	
	# spawn_houseメソッドが存在することを確認
	if not TestRunner.assert_true(game_manager.has_method("spawn_house"), 
		"GameManager should have spawn_house method"):
		return false
	
	# get_random_available_positionメソッドが実装されていることを確認
	var grid_manager = game_manager.get_node("GridManager")
	if not TestRunner.assert_true(grid_manager.has_method("get_random_available_position"), 
		"GridManager should have get_random_available_position method"):
		return false
	
	# ランダムな位置が返されることを確認
	var pos1 = grid_manager.get_random_available_position()
	var pos2 = grid_manager.get_random_available_position()
	
	# 両方の位置が有効であることを確認
	if not TestRunner.assert_true(pos1.x >= 0 and pos1.x < 50 and pos1.y >= 0 and pos1.y < 50, 
		"Random position should be within grid bounds"):
		return false
	
	return true

func test_houses_dont_overlap():
	var game_manager = get_node("/root/GameManager")
	if not game_manager:
		return false
	
	var grid_manager = game_manager.get_node("GridManager")
	
	# グリッドをクリア
	grid_manager.occupied_positions.clear()
	
	# 特定の位置を占有
	grid_manager.occupy_position(10, 10)
	
	# 同じ位置が占有されていることを確認
	if not TestRunner.assert_true(grid_manager.is_occupied(10, 10), 
		"Position (10, 10) should be occupied"):
		return false
	
	# ランダムな位置を100回取得して、占有された位置が返されないことを確認
	for i in range(100):
		var pos = grid_manager.get_random_available_position()
		if pos.x == 10 and pos.y == 10:
			return TestRunner.assert_true(false, 
				"get_random_available_position should not return occupied position")
	
	return true

func test_house_count_matches_expected():
	var game_manager = get_node("/root/GameManager")
	if not game_manager:
		return false
	
	# HouseContainerが存在することを確認
	var house_container = game_manager.get_node_or_null("HouseContainer")
	if not TestRunner.assert_not_null(house_container, 
		"GameManager should have HouseContainer node"):
		return false
	
	# 初期状態を設定
	game_manager.house_count = 0
	game_manager.population = 0
	
	# 家のコンテナをクリア
	for child in house_container.get_children():
		child.queue_free()
	
	# 人口を増やして家が生成されることを確認
	game_manager._on_population_timer_timeout()  # 人口1
	
	# 少し待機（次のフレームで家が生成される）
	await get_tree().process_frame
	
	# 家の数が正しいことを確認
	var actual_house_count = house_container.get_child_count()
	return TestRunner.assert_equal(actual_house_count, 1, 
		"Should have 1 house instance in HouseContainer")
