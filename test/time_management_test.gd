extends Node

# 時間管理システムのテスト

func test_elapsed_time_tracking():
	var game_manager = get_node("/root/GameManager")
	if not game_manager:
		return false
	
	# elapsed_timeプロパティが存在することを確認
	if not "elapsed_time" in game_manager:
		return TestRunner.assert_true(false, "GameManager should have elapsed_time property")
	
	# 初期値が0であることを確認
	return TestRunner.assert_equal(game_manager.elapsed_time, 0.0, "Initial elapsed_time should be 0")

func test_time_scale_changes_speed():
	var game_manager = get_node("/root/GameManager")
	if not game_manager:
		return false
	
	# time_scaleプロパティが存在することを確認
	if not "time_scale" in game_manager:
		return TestRunner.assert_true(false, "GameManager should have time_scale property")
	
	# デフォルト値が1.0であることを確認
	if not TestRunner.assert_equal(game_manager.time_scale, 1.0, "Default time_scale should be 1.0"):
		return false
	
	# time_scaleの設定ができることを確認
	game_manager.time_scale = 10.0
	if not TestRunner.assert_equal(game_manager.time_scale, 10.0, "time_scale should be settable"):
		return false
	
	# set_time_scaleメソッドが存在することを確認
	if not TestRunner.assert_true(game_manager.has_method("set_time_scale"), 
		"GameManager should have set_time_scale method"):
		return false
	
	# メソッドで設定できることを確認
	game_manager.set_time_scale(5.0)
	return TestRunner.assert_equal(game_manager.time_scale, 5.0, 
		"set_time_scale should update time_scale value")

func test_elapsed_time_updates():
	var game_manager = get_node("/root/GameManager")
	if not game_manager:
		return false
	
	# _processメソッドが定義されていることを確認
	if not TestRunner.assert_true(game_manager.has_method("_process"), 
		"GameManager should have _process method"):
		return false
	
	# 時間をリセット
	game_manager.elapsed_time = 0.0
	game_manager.time_scale = 1.0
	
	# _processを手動で呼び出してelapsed_timeが更新されることを確認
	game_manager._process(0.1)  # 0.1秒のdelta
	
	return TestRunner.assert_equal(game_manager.elapsed_time, 0.1, 
		"elapsed_time should increase by delta * time_scale")