extends Node

# パフォーマンステスト

func test_performance_with_100_houses():
	var game_manager = get_node("/root/GameManager")
	var grid_manager = game_manager.get_node("GridManager")
	var house_container = game_manager.get_node("HouseContainer")
	
	# 既存の家をクリア
	for child in house_container.get_children():
		child.queue_free()
	grid_manager.occupied_positions.clear()
	
	# テスト開始時間を記録
	var start_time = Time.get_ticks_msec()
	
	# 100軒の家を生成
	for i in range(100):
		var pos = grid_manager.get_random_available_position()
		if pos.x >= 0:
			grid_manager.occupy_position(pos.x, pos.y)
			var world_pos = Vector3((pos.x - 25) * 1.0, 0, (pos.y - 25) * 1.0)
			game_manager.spawn_house(world_pos)
	
	# 生成にかかった時間を計測
	var elapsed = Time.get_ticks_msec() - start_time
	
	# 1秒以内に完了することを確認
	if not TestRunner.assert_true(elapsed < 1000, 
		"Should spawn 100 houses in less than 1 second (took " + str(elapsed) + "ms)"):
		return false
	
	# 実際に生成された家の数を確認
	await get_tree().process_frame
	var actual_count = house_container.get_child_count()
	
	# 少なくとも90軒以上生成されていることを確認（グリッドの制限があるため）
	return TestRunner.assert_true(actual_count >= 90, 
		"Should spawn at least 90 houses (spawned " + str(actual_count) + ")")