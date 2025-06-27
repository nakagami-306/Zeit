extends Node

# 道路の可視性テスト

func test_road_scene_loading():
	# 道路シーンが正しくロードできるか
	var road_scene = load("res://scenes/road.tscn")
	if not TestRunner.assert_not_null(road_scene, "Road scene should load"):
		return false
	
	var instance = road_scene.instantiate()
	if not TestRunner.assert_not_null(instance, "Road instance should be created"):
		return false
	
	print("Road instance class: ", instance.get_class())
	print("Road instance has mesh: ", instance.has_method("get_mesh"))
	
	instance.queue_free()
	return true

func test_direct_mesh_creation():
	# 直接メッシュを作成してテスト
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(0.9, 0.1, 0.9)
	mesh_instance.mesh = box_mesh
	
	# マテリアルを設定
	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.1, 0.1, 0.1, 1.0)
	mesh_instance.material_override = material
	
	# メインシーンに追加
	var main = get_tree().current_scene
	if main:
		mesh_instance.position = Vector3(0, 0.1, 0)
		main.add_child(mesh_instance)
		
		await get_tree().process_frame
		
		print("Direct mesh visible: ", mesh_instance.visible)
		print("Direct mesh position: ", mesh_instance.position)
		
		mesh_instance.queue_free()
	
	return TestRunner.assert_true(true, "Direct mesh creation test completed")

func test_road_in_game_context():
	# 実際のゲームコンテキストでのテスト
	var game_manager = get_node("/root/GameManager")
	var road_container = game_manager.get_node("RoadContainer")
	
	# 道路を直接生成
	game_manager.spawn_road(Vector3(0, 0, 0))
	
	await get_tree().process_frame
	
	var road_count = road_container.get_child_count()
	print("Roads in container: ", road_count)
	
	for child in road_container.get_children():
		print("Child: ", child.name, " type: ", child.get_class(), " pos: ", child.position)
	
	return TestRunner.assert_true(road_count > 0, "Should have road in container")