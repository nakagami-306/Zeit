extends CanvasLayer

# UI管理スクリプト

@onready var population_label: Label = $VBoxContainer/PopulationLabel
@onready var house_count_label: Label = $VBoxContainer/HouseCountLabel
@onready var time_label: Label = $VBoxContainer/TimeLabel
@onready var time_scale_slider: HSlider = $VBoxContainer/TimeScaleContainer/TimeScaleSlider
@onready var time_scale_label: Label = $VBoxContainer/TimeScaleContainer/TimeScaleLabel

var game_manager: Node

func _ready():
	game_manager = get_node("/root/GameManager")
	
	# スライダーの設定
	time_scale_slider.min_value = 1
	time_scale_slider.max_value = 100
	time_scale_slider.value = 1
	time_scale_slider.value_changed.connect(_on_time_scale_changed)
	
	# 初期表示を更新
	_update_display()

func _process(_delta):
	_update_display()

func _update_display():
	if not game_manager:
		return
	
	# 人口表示
	population_label.text = "人口: %d" % game_manager.population
	
	# 家の数表示
	house_count_label.text = "家: %d" % game_manager.house_count
	
	# 経過時間表示
	var total_seconds = int(game_manager.elapsed_time)
	var hours = total_seconds / 3600
	var minutes = (total_seconds % 3600) / 60
	var seconds = total_seconds % 60
	
	if hours > 0:
		time_label.text = "%02d:%02d:%02d" % [hours, minutes, seconds]
	else:
		time_label.text = "%02d:%02d" % [minutes, seconds]
	
	# 時間スケール表示
	time_scale_label.text = "速度: x%d" % int(time_scale_slider.value)

func _on_time_scale_changed(value: float):
	game_manager.set_time_scale(value)
