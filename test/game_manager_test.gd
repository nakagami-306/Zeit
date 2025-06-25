extends Node

# GameManagerのテスト

func test_game_manager_singleton():
	# GameManagerがAutoloadに登録されているか確認
	var game_manager = get_node_or_null("/root/GameManager")
	return TestRunner.assert_not_null(game_manager, "GameManager should be registered as Autoload")

func test_initial_population_is_zero():
	var game_manager = get_node_or_null("/root/GameManager")
	if not game_manager:
		return false
	
	# populationプロパティが存在し、初期値が0であることを確認
	if "population" in game_manager:
		return TestRunner.assert_equal(game_manager.population, 0, "Initial population should be 0")
	else:
		return TestRunner.assert_true(false, "GameManager should have population property")