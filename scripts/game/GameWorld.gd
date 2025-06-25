extends Node2D

@onready var grid_system: GridSystem = $GridSystem
@onready var camera: Camera2D = $Camera2D
@onready var buildings_container: Node2D = $Buildings
@onready var roads_container: Node2D = $Roads
@onready var grid_visualizer: Node2D = $GridVisualizer

const TILE_SIZE = 64  # タイルの表示サイズ（ピクセル）
const BuildingScene = preload("res://scenes/game/building.tscn")
const CAMERA_SPEED = 500.0  # カメラ移動速度
const CAMERA_EDGE_MARGIN = 50  # 画面端でのカメラ移動マージン

var is_dragging: bool = false
var drag_start_pos: Vector2

func _ready():
	print("GameWorld初期化開始")
	_setup_camera()
	_draw_grid_debug()
	_place_initial_building()

func _setup_camera():
	# アイソメトリック視点の設定
	# カメラを村の中心に配置
	var center_grid = grid_system.current_map_size / 2
	var center_world = _grid_to_screen(center_grid)
	camera.position = center_world
	camera.zoom = Vector2(2, 2)

func _draw():
	if grid_visualizer.visible:
		_draw_grid_lines()

func _draw_grid_lines():
	# デバッグ用のグリッド線を描画
	var grid_size = grid_system.current_map_size
	var tile_width = TILE_SIZE
	var tile_height = TILE_SIZE * 0.5
	
	for x in range(grid_size.x + 1):
		for y in range(grid_size.y + 1):
			var start_pos = _grid_to_screen(Vector2i(x, 0))
			var end_pos = _grid_to_screen(Vector2i(x, grid_size.y))
			draw_line(start_pos, end_pos, Color(0.3, 0.3, 0.3, 0.5), 1)
			
			start_pos = _grid_to_screen(Vector2i(0, y))
			end_pos = _grid_to_screen(Vector2i(grid_size.x, y))
			draw_line(start_pos, end_pos, Color(0.3, 0.3, 0.3, 0.5), 1)

func _grid_to_screen(grid_pos: Vector2i) -> Vector2:
	var x = (grid_pos.x - grid_pos.y) * TILE_SIZE * 0.5
	var y = (grid_pos.x + grid_pos.y) * TILE_SIZE * 0.25
	return Vector2(x, y)

func _place_initial_building():
	# 最初の小屋を中央に配置
	var center = grid_system.current_map_size / 2
	var building_pos = Vector2i(center.x - 1, center.y - 1)
	
	print("マップサイズ: ", grid_system.current_map_size)
	print("中心位置: ", center)
	print("建物配置位置（グリッド）: ", building_pos)
	
	if grid_system.place_building(building_pos, "house_ancient_1"):
		_create_building_visual(building_pos, "house_ancient_1")
		var screen_pos = _grid_to_screen(building_pos)
		print("建物配置位置（スクリーン）: ", screen_pos)
		print("初期建物を配置: ", building_pos)
	else:
		print("建物の配置に失敗！")

func _create_building_visual(grid_pos: Vector2i, building_type: String):
	var building = BuildingScene.instantiate()
	building.grid_position = grid_pos
	building.era = Building.Era.ANCIENT
	
	# 建物タイプに応じたグレード設定
	match building_type:
		"house_ancient_1":
			building.grade = Building.Grade.GRADE_1
		"house_ancient_2":
			building.grade = Building.Grade.GRADE_2
		"house_ancient_3":
			building.grade = Building.Grade.GRADE_3
	
	var screen_pos = _grid_to_screen(grid_pos)
	building.position = screen_pos
	buildings_container.add_child(building)
	
	# 建設アニメーション開始
	building.start_construction(false)

func _draw_grid_debug():
	grid_visualizer.visible = true
	queue_redraw()

func _input(event):
	if event.is_action_pressed("ui_accept"):
		grid_visualizer.visible = !grid_visualizer.visible
		queue_redraw()
	
	# マウスドラッグによるカメラ移動
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				drag_start_pos = event.position
			else:
				is_dragging = false
	
	elif event is InputEventMouseMotion and is_dragging:
		var delta = event.position - drag_start_pos
		camera.position -= delta / camera.zoom
		drag_start_pos = event.position

func _process(delta):
	# キーボードによるカメラ移動
	var move_vector = Vector2.ZERO
	
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		move_vector.x -= 1
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		move_vector.x += 1
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		move_vector.y -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		move_vector.y += 1
	
	# マウスが画面端にある場合の移動
	var mouse_pos = get_viewport().get_mouse_position()
	var viewport_size = get_viewport().get_visible_rect().size
	
	if mouse_pos.x < CAMERA_EDGE_MARGIN:
		move_vector.x -= 1
	elif mouse_pos.x > viewport_size.x - CAMERA_EDGE_MARGIN:
		move_vector.x += 1
	if mouse_pos.y < CAMERA_EDGE_MARGIN:
		move_vector.y -= 1
	elif mouse_pos.y > viewport_size.y - CAMERA_EDGE_MARGIN:
		move_vector.y += 1
	
	if move_vector.length() > 0:
		move_vector = move_vector.normalized()
		camera.position += move_vector * CAMERA_SPEED * delta / camera.zoom.x