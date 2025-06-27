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
	_setup_road_manager()
	_setup_road_container()
	_setup_population_timer()

func _setup_house_container():
	# HouseContainerをメインシーンに追加
	var main_scene = get_tree().current_scene
	if main_scene:
		var container = Node3D.new()
		container.name = "HouseContainer"
		main_scene.add_child(container)
		print("HouseContainer added to main scene")
	else:
		# フォールバック：GameManagerに追加
		var container = Node3D.new()
		container.name = "HouseContainer"
		add_child(container)
		print("HouseContainer added to GameManager (fallback)")

func _setup_grid_manager():
	grid_manager = preload("res://scripts/GridManager.gd").new()
	grid_manager.name = "GridManager"
	add_child(grid_manager)

func _setup_road_manager():
	var road_manager = preload("res://scripts/RoadManager.gd").new()
	road_manager.name = "RoadManager"
	road_manager.grid_manager = grid_manager
	add_child(road_manager)

func _setup_road_container():
	# RoadContainerをメインシーンに追加
	var main_scene = get_tree().current_scene
	if main_scene:
		var container = Node3D.new()
		container.name = "RoadContainer"
		main_scene.add_child(container)
		print("RoadContainer added to main scene")
	else:
		# フォールバック：GameManagerに追加
		var container = Node3D.new()
		container.name = "RoadContainer"
		add_child(container)
		print("RoadContainer added to GameManager (fallback)")

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
		if _spawn_house():  # 家の生成に成功した場合のみカウントを増やす
			house_count += 1
			houses = house_count  # エイリアスを更新
			print("House spawned! Total houses: ", house_count)
			
			# 5軒になったら道路生成の確認
			if house_count == 5:
				print("\n=== 5 houses reached! Triggering road generation ===")

func _calculate_required_houses(pop: int) -> int:
	# 3人につき1軒の家が必要
	if pop == 0:
		return 0
	return int((pop - 1) / 3) + 1

func _spawn_house() -> bool:
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
		
		house_spawned.emit(position)
		
		# 道路生成をチェック
		_check_and_generate_roads()
		
		return true  # 生成成功
	else:
		print("Warning: No available position for new house!")
		# 占有率と現在の半径をデバッグ出力
		var occupancy = grid_manager.calculate_occupancy_rate()
		print("Occupancy rate: ", occupancy * 100, "%, Radius: ", grid_manager.residential_radius)
		return false  # 生成失敗

func spawn_house(position: Vector3):
	# 家のシーンをロード
	var house_scene = preload("res://scenes/house.tscn")
	var house_instance = house_scene.instantiate()
	
	# 位置を設定
	house_instance.position = position
	
	# HouseContainerに追加
	var container = _get_house_container()
	if container:
		container.add_child(house_instance)
	else:
		print("ERROR: HouseContainer not found!")

func _process(delta: float):
	# 経過時間を更新
	elapsed_time += delta * time_scale

func _get_house_container():
	# HouseContainerを取得（メインシーンまたはGameManagerから）
	var main_scene = get_tree().current_scene
	if main_scene and main_scene.has_node("HouseContainer"):
		return main_scene.get_node("HouseContainer")
	elif has_node("HouseContainer"):
		return get_node("HouseContainer")
	else:
		return null

func _get_road_container():
	# RoadContainerを取得（メインシーンまたはGameManagerから）
	var main_scene = get_tree().current_scene
	if main_scene and main_scene.has_node("RoadContainer"):
		return main_scene.get_node("RoadContainer")
	elif has_node("RoadContainer"):
		return get_node("RoadContainer")
	else:
		return null

func set_time_scale(scale: float):
	time_scale = scale
	# タイマーの速度も更新
	var timer = get_node_or_null("PopulationTimer")
	if timer:
		timer.wait_time = 10.0 / time_scale

func _check_and_generate_roads():
	# 道路生成をチェック
	var road_manager = get_node("RoadManager")
	
	# 最小家数をチェック
	if house_count < 5:
		print("Not enough houses for road generation. Current: ", house_count, ", Required: 5")
		return
	
	# 主要道路を生成
	var main_roads = road_manager.generate_main_roads()
	print("Main roads generated: ", main_roads)
	
	# 支線道路を生成
	var branch_roads = road_manager.generate_branch_roads()
	print("Branch roads generated: ", branch_roads)
	
	# 道路インスタンスを生成
	_spawn_road_instances()

func _spawn_road_instances():
	# 道路のビジュアルを生成
	var road_container = _get_road_container()
	if not road_container:
		print("ERROR: RoadContainer not found in _spawn_road_instances!")
		return
	
	# 既存の道路を削除
	for child in road_container.get_children():
		child.queue_free()
	
	# 新しい道路を生成
	var road_count = 0
	for x in range(grid_manager.grid_size.x):
		for y in range(grid_manager.grid_size.y):
			if grid_manager.get_cell_type(x, y) == grid_manager.CellType.ROAD:
				var world_x = (x - 25) * 1.0
				var world_z = (y - 25) * 1.0
				var position = Vector3(world_x, 0, world_z)
				spawn_road(position)
				road_count += 1
	
	print("Road instances created: ", road_count)
	print("RoadContainer children: ", road_container.get_child_count())
	print("RoadContainer parent: ", road_container.get_parent().name if road_container.get_parent() else "None")

func spawn_road(position: Vector3):
	# 道路のシーンをロード
	var road_scene = preload("res://scenes/road.tscn")
	if not road_scene:
		print("ERROR: Cannot load road scene!")
		return
		
	var road_instance = road_scene.instantiate()
	
	# 位置を設定（Y座標を少し上げる）
	road_instance.position = Vector3(position.x, position.y + 0.05, position.z)
	
	# マテリアルを手動で設定
	if road_instance.has_method("get_mesh"):
		var mat = StandardMaterial3D.new()
		mat.albedo_color = Color(0.1, 0.1, 0.1, 1.0)
		road_instance.material_override = mat
	
	# RoadContainerに追加
	var container = _get_road_container()
	if container:
		container.add_child(road_instance)
		# デバッグ：実際に追加されたか確認
		if road_instance.is_inside_tree():
			print("Road spawned at: ", position)
			print("Road instance: ", road_instance.get_class(), " visible: ", road_instance.visible)
	else:
		print("ERROR: RoadContainer not found!")
