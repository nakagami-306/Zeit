extends Control

@onready var time_label: Label = $TopBar/TimeLabel
@onready var population_label: Label = $TopBar/PopulationLabel
@onready var era_label: Label = $TopBar/EraLabel
@onready var speed_label: Label = $DebugPanel/SpeedLabel
@onready var speed_slider: HSlider = $DebugPanel/SpeedSlider

var time_manager: Node
var current_population: int = 2  # 太古グレード1の収容人数に合わせる

func _ready():
	time_manager = get_node("/root/TimeManager")
	
	# シグナル接続
	time_manager.second_passed.connect(_on_second_passed)
	time_manager.population_increase_time.connect(_on_population_increase)
	speed_slider.value_changed.connect(_on_speed_changed)
	
	# 初期値設定
	_update_ui()

func _on_second_passed(_game_time: float):
	_update_ui()

func _on_population_increase():
	# 人口増加（1〜2人ランダム）
	current_population += randi_range(1, 2)
	print("人口増加！ 現在の人口: ", current_population)
	_update_ui()

func _on_speed_changed(value: float):
	time_manager.set_time_scale(value)
	speed_label.text = "速度: x%d" % int(value)

func _update_ui():
	# 時間表示
	time_label.text = time_manager.get_formatted_time()
	
	# 人口表示
	population_label.text = "人口: %d" % current_population
	
	# 時代表示
	var current_era = time_manager.get_current_era()
	era_label.text = _get_era_name(current_era)

func _get_era_name(era: int) -> String:
	match era:
		Building.Era.ANCIENT:
			return "太古時代"
		Building.Era.CLASSICAL:
			return "古典時代"
		Building.Era.MEDIEVAL:
			return "中世"
		Building.Era.RENAISSANCE:
			return "ルネサンス"
		Building.Era.INDUSTRIAL:
			return "産業時代"
		Building.Era.MODERN:
			return "近代"
		Building.Era.ATOMIC:
			return "原子力時代"
		Building.Era.INFORMATION:
			return "情報時代"
		Building.Era.FUTURE:
			return "未来時代"
		_:
			return "不明"

func get_current_population() -> int:
	return current_population