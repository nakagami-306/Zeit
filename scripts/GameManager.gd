extends Node

# ゲーム全体を管理するシングルトン

var population: int = 0
var house_count: int = 0
var houses: int = 0  # house_countのエイリアス（テスト用）
var elapsed_time: float = 0.0
var time_scale: float = 1.0
var grid_manager  # GridManagerへの参照

signal house_spawned(position: Vector3)

func _ready():
	print("GameManager initialized")
	_setup_house_container()
	_setup_grid_manager()
	_setup_population_timer()

func _setup_house_container():
	var container = Node3D.new()
	container.name = "HouseContainer"
	add_child(container)

func _setup_grid_manager():
	grid_manager = preload("res://scripts/GridManager.gd").new()
	grid_manager.name = "GridManager"
	add_child(grid_manager)

func _setup_population_timer():
	var timer = Timer.new()
	timer.name = "PopulationTimer"
	timer.wait_time = 10.0
	add_child(timer)
	timer.autostart = true
	timer.timeout.connect(_on_population_timer_timeout)
	timer.start()

func _on_population_timer_timeout():
	population += 1
	print("Population increased to: ", population)
	_check_house_requirement()

func _check_house_requirement():
	var required_houses = _calculate_required_houses(population)
	if required_houses > house_count:
		_spawn_house()
		house_count += 1
		houses = house_count  # エイリアスを更新
		print("House spawned! Total houses: ", house_count)

func _calculate_required_houses(pop: int) -> int:
	# 3人につき1軒の家が必要
	if pop == 0:
		return 0
	return (pop - 1) / 3 + 1

func _spawn_house():
	# 最初の家は必ず中心に配置
	var grid_pos: Vector2i
	if house_count == 0:
		grid_pos = Vector2i(25, 25)
	else:
		# 2軒目以降は最適位置を選択
		grid_pos = grid_manager.get_best_position()
	
	if grid_pos.x >= 0:  # 有効な位置が見つかった
		# グリッド位置を占有
		grid_manager.occupy_position(grid_pos.x, grid_pos.y)
		
		# グリッド座標をワールド座標に変換（中心を0,0として）
		var world_x = (grid_pos.x - 25) * 1.0  # 1グリッド = 1ユニット
		var world_z = (grid_pos.y - 25) * 1.0
		var position = Vector3(world_x, 0, world_z)
		
		# 実際に家のインスタンスを生成
		spawn_house(position)
		
		# エリア拡大のチェック
		grid_manager.check_and_expand_area()
		
		house_spawned.emit(position)
	else:
		print("Warning: No available position for new house!")

func spawn_house(position: Vector3):
	# 家のシーンをロード
	var house_scene = preload("res://scenes/house.tscn")
	var house_instance = house_scene.instantiate()
	
	# 位置を設定
	house_instance.position = position
	
	# HouseContainerに追加
	var container = get_node("HouseContainer")
	container.add_child(house_instance)

func _process(delta: float):
	# 経過時間を更新
	elapsed_time += delta * time_scale

func set_time_scale(scale: float):
	time_scale = scale
	# タイマーの速度も更新
	var timer = get_node_or_null("PopulationTimer")
	if timer:
		timer.wait_time = 10.0 / time_scale
