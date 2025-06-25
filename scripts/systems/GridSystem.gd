extends Node
class_name GridSystem

const GRID_SIZE = 1  # 1マスのサイズ（ピクセル）
const BLOCK_SIZE = 12  # 1ブロックは12x12マス
const BUILDING_SIZE = 3  # 建物は3x3マス
const ROAD_WIDTH = 1  # 道路は1マス幅

var grid_data: Dictionary = {}  # グリッド上のデータを管理
var current_map_size: Vector2i = Vector2i(24, 24)  # 初期マップサイズ（2x2ブロック）

func _ready():
	print("GridSystem初期化完了")
	_initialize_grid()

func _initialize_grid():
	for x in range(current_map_size.x):
		for y in range(current_map_size.y):
			var pos = Vector2i(x, y)
			grid_data[pos] = {
				"type": "empty",
				"building": null
			}

func world_to_grid(world_pos: Vector2) -> Vector2i:
	var iso_x = (world_pos.x / GRID_SIZE + world_pos.y / GRID_SIZE) / 2
	var iso_y = (world_pos.y / GRID_SIZE - world_pos.x / GRID_SIZE) / 2
	return Vector2i(int(iso_x), int(iso_y))

func grid_to_world(grid_pos: Vector2i) -> Vector2:
	var world_x = (grid_pos.x - grid_pos.y) * GRID_SIZE
	var world_y = (grid_pos.x + grid_pos.y) * GRID_SIZE * 0.5
	return Vector2(world_x, world_y)

func is_valid_position(grid_pos: Vector2i) -> bool:
	return grid_pos.x >= 0 and grid_pos.x < current_map_size.x and \
		   grid_pos.y >= 0 and grid_pos.y < current_map_size.y

func can_place_building(grid_pos: Vector2i) -> bool:
	for x in range(BUILDING_SIZE):
		for y in range(BUILDING_SIZE):
			var check_pos = grid_pos + Vector2i(x, y)
			if not is_valid_position(check_pos):
				return false
			if grid_data.has(check_pos) and grid_data[check_pos]["type"] != "empty":
				return false
	return true

func place_building(grid_pos: Vector2i, building_type: String) -> bool:
	if not can_place_building(grid_pos):
		return false
	
	for x in range(BUILDING_SIZE):
		for y in range(BUILDING_SIZE):
			var pos = grid_pos + Vector2i(x, y)
			grid_data[pos] = {
				"type": "building",
				"building": building_type
			}
	return true

func expand_map_if_needed():
	# 必要に応じてマップを拡張する（将来的な実装）
	pass