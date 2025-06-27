extends Node

# 道路シーンのテスト

func test_road_scene_loads():
	# 道路シーンが存在してロードできることを確認
	var road_scene = load("res://scenes/road.tscn")
	return TestRunner.assert_not_null(road_scene, "Road scene should load successfully")

func test_road_has_mesh():
	var road_scene = load("res://scenes/road.tscn")
	if not road_scene:
		return false
	
	var road_instance = road_scene.instantiate()
	
	# MeshInstance3DまたはCSGBox3Dが存在することを確認
	var mesh_node = null
	if road_instance.has_node("MeshInstance3D"):
		mesh_node = road_instance.get_node("MeshInstance3D")
	elif road_instance.has_node("CSGBox3D"):
		mesh_node = road_instance.get_node("CSGBox3D")
	elif road_instance is MeshInstance3D:
		mesh_node = road_instance
	elif road_instance is CSGBox3D:
		mesh_node = road_instance
	
	road_instance.queue_free()
	
	return TestRunner.assert_not_null(mesh_node, "Road should have a mesh representation")

func test_road_height():
	var road_scene = load("res://scenes/road.tscn")
	if not road_scene:
		return false
	
	var road_instance = road_scene.instantiate()
	
	# 道路の高さが地面より少し高いことを確認（Y座標が0より大きい）
	var height_ok = false
	if road_instance is Node3D:
		# ルートノードの高さをチェック
		height_ok = road_instance.position.y >= 0.0 and road_instance.position.y <= 0.1
	
	# CSGBox3Dの場合、サイズもチェック
	if road_instance is CSGBox3D:
		height_ok = height_ok and road_instance.size.y <= 0.2
	elif road_instance.has_node("CSGBox3D"):
		var box = road_instance.get_node("CSGBox3D")
		height_ok = height_ok and box.size.y <= 0.2
	
	road_instance.queue_free()
	
	return TestRunner.assert_true(height_ok, "Road height should be slightly above ground (0-0.1)")

func test_road_material():
	var road_scene = load("res://scenes/road.tscn")
	if not road_scene:
		return false
	
	var road_instance = road_scene.instantiate()
	
	# マテリアルが設定されていることを確認
	var has_material = false
	if road_instance is CSGBox3D and road_instance.material:
		has_material = true
	elif road_instance is MeshInstance3D and road_instance.material_override:
		has_material = true
	elif road_instance.has_node("CSGBox3D"):
		var box = road_instance.get_node("CSGBox3D")
		has_material = box.material != null
	elif road_instance.has_node("MeshInstance3D"):
		var mesh = road_instance.get_node("MeshInstance3D")
		has_material = mesh.material_override != null or (mesh.mesh and mesh.mesh.surface_get_material(0) != null)
	
	road_instance.queue_free()
	
	return TestRunner.assert_true(has_material, "Road should have a material assigned")