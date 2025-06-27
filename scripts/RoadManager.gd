extends Node

# 道路生成を管理するクラス

var grid_manager  # GridManagerへの参照
var density_radius: int = 3  # 密度計算の半径

# ホットスポットデータ
class Hotspot:
	var position: Vector2i
	var density: float
	
	func _init(pos: Vector2i, dens: float):
		position = pos
		density = dens

func calculate_density_map() -> Dictionary:
	# 各グリッド位置の密度を計算
	var density_map = {}
	
	if not grid_manager:
		return density_map
	
	for x in range(grid_manager.grid_size.x):
		for y in range(grid_manager.grid_size.y):
			var density = _calculate_density_at(x, y)
			if density > 0:
				var key = "%d,%d" % [x, y]
				density_map[key] = density
	
	return density_map

func _calculate_density_at(x: int, y: int) -> float:
	# 指定位置の周囲の家の密度を計算
	var house_count = 0
	var total_cells = 0
	
	for dx in range(-density_radius, density_radius + 1):
		for dy in range(-density_radius, density_radius + 1):
			var check_x = x + dx
			var check_y = y + dy
			
			# 距離チェック（円形範囲）
			var distance = sqrt(dx * dx + dy * dy)
			if distance > density_radius:
				continue
			
			if grid_manager.is_valid_position(check_x, check_y):
				total_cells += 1
				if grid_manager.get_cell_type(check_x, check_y) == grid_manager.CellType.HOUSE:
					house_count += 1
	
	if total_cells == 0:
		return 0.0
	
	return float(house_count) / float(total_cells)

func get_density_at(x: int, y: int, density_map: Dictionary) -> float:
	# 密度マップから指定位置の密度を取得
	var key = "%d,%d" % [x, y]
	if density_map.has(key):
		return density_map[key]
	return 0.0

func find_hotspots() -> Array:
	# 密度の高い場所（ホットスポット）を検出
	var density_map = calculate_density_map()
	var hotspots = []
	
	# すべての位置を密度でソート
	for key in density_map:
		var parts = key.split(",")
		var x = int(parts[0])
		var y = int(parts[1])
		var density = density_map[key]
		
		if density > 0:
			var hotspot = Hotspot.new(Vector2i(x, y), density)
			hotspots.append(hotspot)
	
	# 密度でソート（降順）
	hotspots.sort_custom(func(a, b): return a.density > b.density)
	
	return hotspots

func get_top_hotspots(count: int) -> Array:
	# 上位N個のホットスポットを取得
	var all_hotspots = find_hotspots()
	var top_hotspots = []
	
	for i in range(min(count, all_hotspots.size())):
		top_hotspots.append(all_hotspots[i])
	
	return top_hotspots

func find_path(start: Vector2i, end: Vector2i) -> Array:
	# 簡易的なA*経路探索
	if start == end:
		return [start]
	
	var open_set = [start]
	var came_from = {}
	var g_score = {_vec_to_key(start): 0}
	var f_score = {_vec_to_key(start): start.distance_to(end)}
	
	while open_set.size() > 0:
		# 最小f_scoreのノードを選択
		var current = open_set[0]
		var current_f = f_score[_vec_to_key(current)]
		
		for node in open_set:
			var node_f = f_score.get(_vec_to_key(node), INF)
			if node_f < current_f:
				current = node
				current_f = node_f
		
		if current == end:
			# パスを再構築
			return _reconstruct_path(came_from, current)
		
		open_set.erase(current)
		
		# 4方向の隣接ノードをチェック
		var neighbors = [
			current + Vector2i(1, 0),
			current + Vector2i(-1, 0),
			current + Vector2i(0, 1),
			current + Vector2i(0, -1)
		]
		
		for neighbor in neighbors:
			if not grid_manager.is_valid_position(neighbor.x, neighbor.y):
				continue
			
			# 家は通れない
			if grid_manager.get_cell_type(neighbor.x, neighbor.y) == grid_manager.CellType.HOUSE:
				continue
			
			var tentative_g = g_score[_vec_to_key(current)] + 1
			var neighbor_key = _vec_to_key(neighbor)
			
			if tentative_g < g_score.get(neighbor_key, INF):
				came_from[neighbor_key] = current
				g_score[neighbor_key] = tentative_g
				f_score[neighbor_key] = tentative_g + neighbor.distance_to(end)
				
				if neighbor not in open_set:
					open_set.append(neighbor)
	
	# パスが見つからない
	return []

func _vec_to_key(vec: Vector2i) -> String:
	return "%d,%d" % [vec.x, vec.y]

func _reconstruct_path(came_from: Dictionary, current: Vector2i) -> Array:
	var path = [current]
	var current_key = _vec_to_key(current)
	
	while current_key in came_from:
		current = came_from[current_key]
		path.push_front(current)
		current_key = _vec_to_key(current)
	
	return path

func generate_manhattan_path(start: Vector2i, end: Vector2i) -> Array:
	# マンハッタン距離での経路生成（直角のみ）
	var path = [start]
	var current = start
	
	# まずX方向に移動
	while current.x != end.x:
		if current.x < end.x:
			current.x += 1
		else:
			current.x -= 1
		path.append(current)
	
	# 次にY方向に移動
	while current.y != end.y:
		if current.y < end.y:
			current.y += 1
		else:
			current.y -= 1
		path.append(current)
	
	return path

func is_path_blocked(path: Array) -> bool:
	# パスが家によってブロックされているかチェック
	for point in path:
		if grid_manager.get_cell_type(point.x, point.y) == grid_manager.CellType.HOUSE:
			return true
	return false

var min_houses_for_roads: int = 5  # 道路生成開始の最小家数

func generate_main_roads() -> int:
	# 主要道路を生成
	var roads_placed = 0
	
	# 最小家数チェック
	var house_count = 0
	for x in range(grid_manager.grid_size.x):
		for y in range(grid_manager.grid_size.y):
			if grid_manager.get_cell_type(x, y) == grid_manager.CellType.HOUSE:
				house_count += 1
	
	if house_count < min_houses_for_roads:
		return 0
	
	# ホットスポットを取得
	var hotspots = get_top_hotspots(3)
	
	# ホットスポット間を接続
	for i in range(hotspots.size() - 1):
		for j in range(i + 1, hotspots.size()):
			if connect_hotspots(hotspots[i].position, hotspots[j].position):
				roads_placed += 1
	
	return roads_placed

func connect_hotspots(start: Vector2i, end: Vector2i) -> bool:
	# 2つのホットスポット間を道路で接続
	var path = find_path(start, end)
	
	if path.is_empty():
		# 障害物を無視してマンハッタン経路で接続
		path = generate_manhattan_path(start, end)
	
	return place_road_segment(path)

func place_road_segment(segment: Array) -> bool:
	# 道路セグメントを配置
	if segment.is_empty():
		return false
	
	var placed_any = false
	
	for point in segment:
		if grid_manager.is_valid_road_position(point.x, point.y):
			grid_manager.occupy_road(point.x, point.y)
			placed_any = true
	
	return placed_any

func generate_branch_roads() -> int:
	# 支線道路を生成（家から最寄りの道路まで）
	var branches_created = 0
	
	# すべての家を取得
	var houses = []
	for x in range(grid_manager.grid_size.x):
		for y in range(grid_manager.grid_size.y):
			if grid_manager.get_cell_type(x, y) == grid_manager.CellType.HOUSE:
				houses.append(Vector2i(x, y))
	
	# 各家を道路に接続
	for house in houses:
		if not is_house_connected_to_road(house):
			if connect_house_to_road(house):
				branches_created += 1
	
	return branches_created

func is_house_connected_to_road(house_pos: Vector2i) -> bool:
	# 家が道路に隣接しているかチェック
	var neighbors = [
		house_pos + Vector2i(1, 0),
		house_pos + Vector2i(-1, 0),
		house_pos + Vector2i(0, 1),
		house_pos + Vector2i(0, -1)
	]
	
	for neighbor in neighbors:
		if grid_manager.is_valid_position(neighbor.x, neighbor.y):
			if grid_manager.get_cell_type(neighbor.x, neighbor.y) == grid_manager.CellType.ROAD:
				return true
	
	return false

func find_nearest_road(position: Vector2i) -> Vector2i:
	# 最寄りの道路を探す
	var nearest_road = Vector2i(-1, -1)
	var min_distance = INF
	
	for x in range(grid_manager.grid_size.x):
		for y in range(grid_manager.grid_size.y):
			if grid_manager.get_cell_type(x, y) == grid_manager.CellType.ROAD:
				var road_pos = Vector2i(x, y)
				var distance = position.distance_to(road_pos)
				if distance < min_distance:
					min_distance = distance
					nearest_road = road_pos
	
	return nearest_road

func connect_house_to_road(house_pos: Vector2i) -> bool:
	# 家を最寄りの道路に接続
	var nearest_road = find_nearest_road(house_pos)
	
	if nearest_road == Vector2i(-1, -1):
		return false
	
	# 家の隣の空き地から道路まで経路を作成
	var start_positions = []
	var neighbors = [
		house_pos + Vector2i(1, 0),
		house_pos + Vector2i(-1, 0),
		house_pos + Vector2i(0, 1),
		house_pos + Vector2i(0, -1)
	]
	
	for neighbor in neighbors:
		if grid_manager.is_valid_position(neighbor.x, neighbor.y):
			if grid_manager.get_cell_type(neighbor.x, neighbor.y) == grid_manager.CellType.EMPTY:
				start_positions.append(neighbor)
	
	if start_positions.is_empty():
		return false
	
	# 最短の開始位置を選択
	var best_start = start_positions[0]
	var min_dist = best_start.distance_to(nearest_road)
	
	for start in start_positions:
		var dist = start.distance_to(nearest_road)
		if dist < min_dist:
			min_dist = dist
			best_start = start
	
	# 経路を生成して配置
	var path = find_path(best_start, nearest_road)
	if path.is_empty():
		path = generate_manhattan_path(best_start, nearest_road)
	
	return place_road_segment(path)
