extends Camera3D

# カメラコントロールスクリプト

var movement_speed: float = 10.0
var drag_start_position: Vector2
var is_dragging: bool = false

func _ready():
	# 初期位置を設定
	position = Vector3(10, 10, 10)

func _process(delta: float):
	_handle_keyboard_movement(delta)

func _handle_keyboard_movement(delta: float):
	var movement = Vector3.ZERO
	
	# WASDキーでの移動
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		movement.x -= 1
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		movement.x += 1
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		movement.z -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		movement.z += 1
	
	# 移動を適用
	if movement.length() > 0:
		movement = movement.normalized() * movement_speed * delta
		position += movement
		_clamp_position()

func _input(event: InputEvent):
	# マウスドラッグの処理
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				is_dragging = true
				drag_start_position = event.position
			else:
				is_dragging = false
	
	elif event is InputEventMouseMotion and is_dragging:
		var delta = event.position - drag_start_position
		drag_start_position = event.position
		
		# ドラッグ量をカメラ移動に変換
		var movement = Vector3(-delta.x * 0.05, 0, -delta.y * 0.05)
		position += movement
		_clamp_position()

func _clamp_position():
	# カメラの移動範囲を制限
	position.x = clamp(position.x, -15, 35)
	position.z = clamp(position.z, -15, 35)
	# Y位置は固定
	position.y = 10