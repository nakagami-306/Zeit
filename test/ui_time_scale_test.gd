extends Node

# UI時間加速スライダーのテスト

func test_time_scale_slider_range():
	# UIシーンをロード
	var ui_scene = load("res://scenes/ui.tscn")
	var ui_instance = ui_scene.instantiate()
	add_child(ui_instance)
	
	# スライダーを取得
	var slider = ui_instance.get_node("VBoxContainer/TimeScaleContainer/TimeScaleSlider")
	if not TestRunner.assert_not_null(slider, "TimeScaleSlider should exist"):
		ui_instance.queue_free()
		return false
	
	# 範囲を確認
	if not TestRunner.assert_equal(slider.min_value, 1.0, "Slider min value should be 1"):
		ui_instance.queue_free()
		return false
	
	var result = TestRunner.assert_equal(slider.max_value, 100.0, "Slider max value should be 100")
	
	ui_instance.queue_free()
	return result

func test_time_scale_affects_population_timer():
	# UIシーンをロード
	var ui_scene = load("res://scenes/ui.tscn")
	var ui_instance = ui_scene.instantiate()
	add_child(ui_instance)
	
	# GameManagerを取得
	var game_manager = get_node("/root/GameManager")
	
	# スライダーとラベルを取得
	var slider = ui_instance.get_node("VBoxContainer/TimeScaleContainer/TimeScaleSlider")
	var scale_label = ui_instance.get_node("VBoxContainer/TimeScaleContainer/TimeScaleLabel")
	
	# スライダーの値を変更
	slider.value = 10.0
	slider.value_changed.emit(10.0)
	await get_tree().process_frame
	
	# GameManagerのtime_scaleが更新されたことを確認
	if not TestRunner.assert_equal(game_manager.time_scale, 10.0, 
		"GameManager time_scale should be updated to 10"):
		ui_instance.queue_free()
		return false
	
	# ラベルが更新されたことを確認
	var result = TestRunner.assert_equal(scale_label.text, "速度: x10", 
		"Time scale label should show 'x10'")
	
	ui_instance.queue_free()
	return result