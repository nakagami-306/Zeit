extends Node2D
class_name Building

enum Era {
	ANCIENT,
	CLASSICAL,
	MEDIEVAL,
	RENAISSANCE,
	INDUSTRIAL,
	MODERN,
	ATOMIC,
	INFORMATION,
	FUTURE
}

enum Grade {
	GRADE_1 = 1,
	GRADE_2 = 2,
	GRADE_3 = 3
}

@export var era: Era = Era.ANCIENT
@export var grade: Grade = Grade.GRADE_1
@export var grid_position: Vector2i
@export var population_capacity: int = 2
@export var is_under_construction: bool = false

var building_sprite: ColorRect
var construction_overlay: Node2D
var construction_time: float = 20.0  # 新規建築時間
var upgrade_time: float = 5.0  # アップグレード時間
var current_construction_time: float = 0.0

const BUILDING_COLORS = {
	Era.ANCIENT: {
		Grade.GRADE_1: Color(0.6, 0.4, 0.2),    # 茶色
		Grade.GRADE_2: Color(0.5, 0.3, 0.1),    # 濃い茶色
		Grade.GRADE_3: Color(0.7, 0.3, 0.2)     # 赤茶色
	}
}

const POPULATION_CAPACITY = {
	Era.ANCIENT: {
		Grade.GRADE_1: 2,
		Grade.GRADE_2: 3,
		Grade.GRADE_3: 4
	}
}

func _ready():
	print("Building初期化 - Era: ", era, " Grade: ", grade)
	_create_visual()
	_update_visual()
	print("Building色: ", building_sprite.color)
	print("Building位置: ", position)
	print("Sprite位置: ", building_sprite.position)

func _create_visual():
	# 建物の見た目を作成
	building_sprite = ColorRect.new()
	building_sprite.size = Vector2(192, 192)  # 3x3グリッド * 64ピクセル
	building_sprite.position = Vector2(-96, -96)  # 中心に配置するためのオフセット
	add_child(building_sprite)
	
	# 建設中のオーバーレイ
	construction_overlay = Node2D.new()
	add_child(construction_overlay)

func _update_visual():
	if BUILDING_COLORS.has(era) and BUILDING_COLORS[era].has(grade):
		building_sprite.color = BUILDING_COLORS[era][grade]
	
	if POPULATION_CAPACITY.has(era) and POPULATION_CAPACITY[era].has(grade):
		population_capacity = POPULATION_CAPACITY[era][grade]
	
	if is_under_construction:
		_show_construction()
	else:
		_hide_construction()

func _show_construction():
	# 足場の表示（黄色い枠）
	construction_overlay.show()
	building_sprite.modulate.a = 0.5
	queue_redraw()

func _hide_construction():
	construction_overlay.hide()
	building_sprite.modulate.a = 1.0
	queue_redraw()

func _draw():
	if is_under_construction:
		# 黄色い枠を描画
		draw_rect(Rect2(building_sprite.position, building_sprite.size), Color(1, 1, 0, 0.8), false, 4.0)

func start_construction(is_upgrade: bool = false):
	is_under_construction = true
	current_construction_time = upgrade_time if is_upgrade else construction_time
	_update_visual()

func complete_construction():
	is_under_construction = false
	_update_visual()

func upgrade():
	if grade < Grade.GRADE_3:
		grade = grade + 1
		start_construction(true)
		return true
	else:
		# 次の時代への移行（将来的な実装）
		return false

func get_info() -> Dictionary:
	return {
		"era": era,
		"grade": grade,
		"population": population_capacity,
		"position": grid_position,
		"under_construction": is_under_construction
	}