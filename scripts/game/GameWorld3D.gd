extends Node3D

@onready var camera: Camera3D = $Camera3D
@onready var grid_mesh_container: Node3D = $GridMesh
@onready var buildings_container: Node3D = $Buildings
@onready var roads_container: Node3D = $Roads

const GRID_SIZE = 1.0  # 1グリッドのサイズ（メートル）
const BLOCK_SIZE = 12  # 1ブロックは12x12グリッド
const BUILDING_SIZE = 3  # 建物は3x3グリッド
const CAMERA_SPEED = 20.0  # カメラ移動速度
const CAMERA_ZOOM_SPEED = 2.0  # ズーム速度

var grid_system: GridSystem
var is_dragging: bool = false
var drag_start_pos: Vector2
var show_grid: bool = true

func _ready():
	print("GameWorld3D初期化開始")
	grid_system = preload("res://scripts/systems/GridSystem.gd").new()
	add_child(grid_system)
	
	_setup_camera()
	_create_grid_mesh()
	_place_initial_building()

func _setup_camera():
	# アイソメトリック視点の設定（45度の角度から見下ろす）
	camera.position = Vector3(10, 10, 10)
	camera.look_at(Vector3.ZERO, Vector3.UP)
	camera.size = 20.0  # Orthogonal投影のサイズ

func _create_grid_mesh():
	# グリッドの可視化（デバッグ用）
	var grid_size = grid_system.current_map_size
	var mesh_instance = MeshInstance3D.new()
	var immediate_mesh = ImmediateMesh.new()
	var material = StandardMaterial3D.new()
	
	material.vertex_color_use_as_albedo = true
	material.albedo_color = Color(0.3, 0.3, 0.3, 0.5)
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.material_override = material
	grid_mesh_container.add_child(mesh_instance)
	
	# グリッド線の生成
	for x in range(grid_size.x + 1):
		var start = Vector3(x * GRID_SIZE, 0, 0)
		var end = Vector3(x * GRID_SIZE, 0, grid_size.y * GRID_SIZE)
		_draw_line(immediate_mesh, start, end, Color(0.3, 0.3, 0.3))
	
	for z in range(grid_size.y + 1):
		var start = Vector3(0, 0, z * GRID_SIZE)
		var end = Vector3(grid_size.x * GRID_SIZE, 0, z * GRID_SIZE)
		_draw_line(immediate_mesh, start, end, Color(0.3, 0.3, 0.3))

func _draw_line(immediate_mesh: ImmediateMesh, start: Vector3, end: Vector3, color: Color):
	# この関数は後で適切なグリッド表示に置き換えます
	pass

func _place_initial_building():
	# 最初の小屋を中央に配置
	var center = grid_system.current_map_size / 2
	var building_pos = Vector2i(center.x - 1, center.y - 1)
	
	if grid_system.place_building(building_pos, "house_ancient_1"):
		_create_building_3d(building_pos, "house_ancient_1")
		print("初期建物を配置: ", building_pos)

func _create_building_3d(grid_pos: Vector2i, building_type: String):
	# 簡易的な3D建物（BoxMesh）
	var building = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(BUILDING_SIZE * GRID_SIZE * 0.9, 2.0, BUILDING_SIZE * GRID_SIZE * 0.9)
	
	building.mesh = box_mesh
	
	# マテリアルの設定
	var material = StandardMaterial3D.new()
	match building_type:
		"house_ancient_1":
			material.albedo_color = Color(0.6, 0.4, 0.2)  # 茶色
		"house_ancient_2":
			material.albedo_color = Color(0.5, 0.3, 0.1)  # 濃い茶色
		"house_ancient_3":
			material.albedo_color = Color(0.7, 0.3, 0.2)  # 赤茶色
	
	building.material_override = material
	
	# 位置の設定
	var world_pos = grid_to_world(grid_pos)
	building.position = world_pos + Vector3(BUILDING_SIZE * GRID_SIZE * 0.5, 1.0, BUILDING_SIZE * GRID_SIZE * 0.5)
	
	buildings_container.add_child(building)
	
	# 建設中の表示（黄色い枠）
	_create_construction_indicator(building)

func _create_construction_indicator(building: MeshInstance3D):
	# 建設中の黄色い枠
	var indicator = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(BUILDING_SIZE * GRID_SIZE, 2.2, BUILDING_SIZE * GRID_SIZE)
	
	indicator.mesh = box_mesh
	
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(1, 1, 0, 0.8)
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.no_depth_test = true
	material.cull_mode = BaseMaterial3D.CULL_DISABLED
	
	indicator.material_override = material
	indicator.position = Vector3.ZERO
	
	building.add_child(indicator)

func grid_to_world(grid_pos: Vector2i) -> Vector3:
	return Vector3(grid_pos.x * GRID_SIZE, 0, grid_pos.y * GRID_SIZE)

func world_to_grid(world_pos: Vector3) -> Vector2i:
	return Vector2i(int(world_pos.x / GRID_SIZE), int(world_pos.z / GRID_SIZE))

func _input(event):
	# グリッド表示のトグル
	if event.is_action_pressed("ui_accept"):
		show_grid = !show_grid
		grid_mesh_container.visible = show_grid
	
	# マウスドラッグによるカメラ移動
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = event.pressed
			drag_start_pos = event.position
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			camera.size = max(5.0, camera.size - CAMERA_ZOOM_SPEED)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			camera.size = min(50.0, camera.size + CAMERA_ZOOM_SPEED)
	
	elif event is InputEventMouseMotion and is_dragging:
		var delta = event.position - drag_start_pos
		var move = Vector3(-delta.x, 0, -delta.y) * 0.05
		camera.position += move
		drag_start_pos = event.position

func _process(delta):
	# キーボードによるカメラ移動
	var move_vector = Vector3.ZERO
	
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		move_vector.x -= 1
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		move_vector.x += 1
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		move_vector.z -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		move_vector.z += 1
	
	if move_vector.length() > 0:
		move_vector = move_vector.normalized()
		camera.position += move_vector * CAMERA_SPEED * delta