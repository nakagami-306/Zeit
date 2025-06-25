extends Node2D

func _ready():
	print("Zeit - 村発展シミュレーション開始")
	_setup_viewport()

func _setup_viewport():
	get_viewport().size = Vector2(1280, 720)
	print("ビューポートサイズ設定完了: 1280x720")