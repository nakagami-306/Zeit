extends Node

# グリッドシステムを管理するクラス

var grid_size: Vector2i = Vector2i(50, 50)
var occupied_positions: Dictionary = {}

# 円形住宅エリアのプロパティ
var center_position: Vector2i = Vector2i(25, 25)
var residential_radius: float = 5.0
var max_radius: float = 20.0

# 配置優先度の重みパラメータ
var adjacency_weight: float = 10.0  # 隣接ボーナスの重み
var density_weight: float = 2.0     # 密度ボーナスの重み
var distance_weight: float = 0.5    # 距離ペナルティの重み

# エリア拡大のパラメータ
var expansion_threshold: float = 0.7  # 70%を超えたら拡大

func is_valid_position(x: int, y: int) -> bool:
	return x >= 0 and x < grid_size.x and y >= 0 and y < grid_size.y

func is_occupied(x: int, y: int) -> bool:
	var key = "%d,%d" % [x, y]
	return occupied_positions.has(key)

func occupy_position(x: int, y: int):
	if is_valid_position(x, y):
		var key = "%d,%d" % [x, y]
		occupied_positions[key] = true

func clear_position(x: int, y: int):
	var key = "%d,%d" % [x, y]
	occupied_positions.erase(key)

func is_within_residential_area(position: Vector2i) -> bool:
	# 中心からの距離を計算して、住宅エリア内かどうかを判定
	var distance = position.distance_to(center_position)
	return distance <= residential_radius

func get_adjacent_buildings_count(position: Vector2i) -> int:
	# 4方向の隣接建物をカウント
	var count = 0
	var directions = [
		Vector2i(0, -1),  # 北
		Vector2i(1, 0),   # 東
		Vector2i(0, 1),   # 南
		Vector2i(-1, 0)   # 西
	]
	
	for dir in directions:
		var check_pos = position + dir
		if is_valid_position(check_pos.x, check_pos.y) and is_occupied(check_pos.x, check_pos.y):
			count += 1
	
	return count

func get_area_density(position: Vector2i, radius: int = 1) -> float:
	# 指定半径内の建物密度を計算
	var building_count = 0
	var total_cells = 0
	
	for x in range(-radius, radius + 1):
		for y in range(-radius, radius + 1):
			var check_pos = position + Vector2i(x, y)
			if is_valid_position(check_pos.x, check_pos.y):
				total_cells += 1
				if is_occupied(check_pos.x, check_pos.y):
					building_count += 1
	
	if total_cells == 0:
		return 0.0
	
	return float(building_count) / float(total_cells)

func calculate_placement_priority(position: Vector2i) -> float:
	# 配置優先度を計算
	var priority = 0.0
	
	# 1. 隣接ボーナス
	var adjacent_count = get_adjacent_buildings_count(position)
	priority += adjacent_count * adjacency_weight
	
	# 2. 密度ボーナス
	var area_density = get_area_density(position, 1)
	priority += area_density * density_weight
	
	# 3. 距離ペナルティ
	var distance = position.distance_to(center_position)
	priority -= distance * distance_weight
	
	return priority

func get_available_positions() -> Array:
	# 住宅エリア内の利用可能な位置をすべて取得
	var available = []
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var pos = Vector2i(x, y)
			if is_within_residential_area(pos) and not is_occupied(x, y):
				available.append(pos)
	return available

func get_best_position() -> Vector2i:
	# 最適な配置位置を返す
	var available_positions = get_available_positions()
	
	if available_positions.is_empty():
		return Vector2i(-1, -1)
	
	# 各位置の優先度を計算
	var best_position = available_positions[0]
	var best_priority = calculate_placement_priority(best_position)
	var candidates = [best_position]  # 同点の候補を保持
	
	for i in range(1, available_positions.size()):
		var pos = available_positions[i]
		var priority = calculate_placement_priority(pos)
		
		if priority > best_priority:
			best_priority = priority
			best_position = pos
			candidates = [pos]
		elif priority == best_priority:
			candidates.append(pos)
	
	# 同点の場合はランダムに選択
	if candidates.size() > 1:
		return candidates[randi() % candidates.size()]
	
	return best_position

func calculate_occupancy_rate() -> float:
	# 住宅エリア内の占有率を計算
	var total_cells = 0
	var occupied_cells = 0
	
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			var pos = Vector2i(x, y)
			if is_within_residential_area(pos):
				total_cells += 1
				if is_occupied(x, y):
					occupied_cells += 1
	
	if total_cells == 0:
		return 0.0
	
	return float(occupied_cells) / float(total_cells)

func expand_residential_area():
	# 住宅エリアを拡大（最大半径まで）
	if residential_radius < max_radius:
		residential_radius += 1.0
		print("Residential area expanded to radius: ", residential_radius)

func check_and_expand_area():
	# 占有率をチェックして必要なら拡大
	var occupancy = calculate_occupancy_rate()
	if occupancy >= expansion_threshold and residential_radius < max_radius:
		expand_residential_area()

func get_random_available_position() -> Vector2i:
	# 利用可能な位置が見つかるまで試行
	var max_attempts = 100
	for i in range(max_attempts):
		var x = randi() % grid_size.x
		var y = randi() % grid_size.y
		if not is_occupied(x, y):
			return Vector2i(x, y)
	
	# 見つからない場合は無効な位置を返す
	return Vector2i(-1, -1)