extends Node

# 家の生成に関するテスト

func test_first_house_spawns_at_population_1():
	var game_manager = get_node("/root/GameManager")
	if not game_manager:
		return false
	
	# house_countプロパティが存在することを確認
	if not "house_count" in game_manager:
		return TestRunner.assert_true(false, "GameManager should have house_count property")
	
	# 初期状態では家が0軒
	game_manager.house_count = 0
	game_manager.population = 0
	
	# 人口を1に増やす
	game_manager._on_population_timer_timeout()
	
	# 家が1軒になっていることを確認
	return TestRunner.assert_equal(game_manager.house_count, 1, 
		"Should have 1 house when population reaches 1")

func test_second_house_spawns_at_population_4():
	var game_manager = get_node("/root/GameManager")
	if not game_manager:
		return false
	
	# 初期状態を設定
	game_manager.house_count = 1
	game_manager.population = 3
	
	# 人口を4に増やす
	game_manager._on_population_timer_timeout()
	
	# 家が2軒になっていることを確認
	return TestRunner.assert_equal(game_manager.house_count, 2, 
		"Should have 2 houses when population reaches 4")

func test_house_capacity_calculation():
	var game_manager = get_node("/root/GameManager")
	if not game_manager:
		return false
	
	# _calculate_required_housesメソッドが存在することを確認
	if not TestRunner.assert_true(game_manager.has_method("_calculate_required_houses"), 
		"GameManager should have _calculate_required_houses method"):
		return false
	
	# 各人口での必要な家の数を確認
	var test_cases = [
		[0, 0],  # 人口0 -> 家0
		[1, 1],  # 人口1 -> 家1
		[2, 1],  # 人口2 -> 家1
		[3, 1],  # 人口3 -> 家1
		[4, 2],  # 人口4 -> 家2
		[6, 2],  # 人口6 -> 家2
		[7, 3],  # 人口7 -> 家3
	]
	
	for test_case in test_cases:
		var population = test_case[0]
		var expected_houses = test_case[1]
		var result = game_manager._calculate_required_houses(population)
		if not TestRunner.assert_equal(result, expected_houses, 
			"Population " + str(population) + " should require " + str(expected_houses) + " houses"):
			return false
	
	return true