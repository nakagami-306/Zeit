extends Node

signal second_passed(game_time: float)
signal minute_passed(game_minutes: int)
signal hour_passed(game_hours: int)
signal population_increase_time()

@export var time_scale: float = 1.0  # 時間の進行速度
@export var is_paused: bool = false

var game_time: float = 0.0  # ゲーム内経過時間（秒）
var real_time: float = 0.0  # 実際の経過時間（秒）
var last_population_increase: float = 0.0

const SECONDS_PER_GAME_MINUTE = 1.0  # リアルタイム1秒 = ゲーム内1分
const POPULATION_INCREASE_INTERVAL = 30.0  # 30秒ごとに人口増加

func _ready():
	print("TimeManager初期化完了")
	set_process(true)

func _process(delta: float):
	if is_paused or not is_app_focused():
		return
	
	# 時間を進める
	var scaled_delta = delta * time_scale
	real_time += scaled_delta
	game_time += scaled_delta * 60.0  # ゲーム内時間（1秒 = 1分）
	
	# 秒ごとのシグナル
	emit_signal("second_passed", game_time)
	
	# 分ごとのシグナル
	if int(game_time) % 60 == 0 and int(game_time) != int(game_time - scaled_delta * 60.0):
		emit_signal("minute_passed", int(game_time) / 60)
	
	# 時間ごとのシグナル
	if int(game_time) % 3600 == 0 and int(game_time) != int(game_time - scaled_delta * 60.0):
		emit_signal("hour_passed", int(game_time) / 3600)
	
	# 人口増加タイミング
	if real_time - last_population_increase >= POPULATION_INCREASE_INTERVAL:
		last_population_increase = real_time
		emit_signal("population_increase_time")

func is_app_focused() -> bool:
	# アプリがフォアグラウンドにあるかチェック
	# Windows環境での動作を考慮
	var window = get_window()
	if window:
		return window.has_focus()
	return true

func set_time_scale(scale: float):
	time_scale = clamp(scale, 0.1, 1000.0)
	print("時間スケール変更: x", time_scale)

func pause():
	is_paused = true

func resume():
	is_paused = false

func get_formatted_time() -> String:
	var total_minutes = int(game_time / 60.0)
	var hours = total_minutes / 60
	var minutes = total_minutes % 60
	var days = hours / 24
	hours = hours % 24
	
	if days > 0:
		return "%d日 %02d:%02d" % [days, hours, minutes]
	else:
		return "%02d:%02d" % [hours, minutes]

func get_current_era() -> int:
	# 時間に基づいて現在の時代を返す（将来的な実装）
	var hours = int(game_time / 3600.0)
	
	# 仮の時代進行（各時代10時間）
	if hours < 10:
		return Building.Era.ANCIENT
	elif hours < 20:
		return Building.Era.CLASSICAL
	else:
		return Building.Era.ANCIENT  # 今はまだ太古時代のみ

func get_save_data() -> Dictionary:
	return {
		"game_time": game_time,
		"real_time": real_time,
		"last_population_increase": last_population_increase
	}

func load_save_data(data: Dictionary):
	game_time = data.get("game_time", 0.0)
	real_time = data.get("real_time", 0.0)
	last_population_increase = data.get("last_population_increase", 0.0)