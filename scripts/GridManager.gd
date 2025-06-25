extends Node

# グリッドシステムを管理するクラス

var grid_size: Vector2i = Vector2i(50, 50)
var occupied_positions: Dictionary = {}

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