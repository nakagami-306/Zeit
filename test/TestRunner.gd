extends Node

# テストランナー - すべてのテストを実行し、結果を報告する
class_name TestRunner

var test_results = {
	"passed": 0,
	"failed": 0,
	"errors": []
}

func _ready():
	print("\n=== Zeit Test Runner ===")
	run_all_tests()
	print_results()
	
	# テスト完了後、自動的に終了
	if test_results.failed == 0:
		print("\n✅ All tests passed!")
	else:
		print("\n❌ Some tests failed!")
	
	# テスト完了後、プロセスを終了
	await get_tree().create_timer(0.1).timeout
	get_tree().quit(test_results.failed)

func run_all_tests():
	# テストディレクトリ内のすべてのテストファイルを探す
	var test_files = []
	var dir = DirAccess.open("res://test/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with("_test.gd"):
				test_files.append(file_name)
			file_name = dir.get_next()
	
	# 各テストファイルを実行
	for test_file in test_files:
		var test_path = "res://test/" + test_file
		var test_script = load(test_path)
		if test_script:
			print("\n📁 Running tests in: " + test_file)
			var test_instance = test_script.new()
			run_tests_in_object(test_instance)
			test_instance.queue_free()

func run_tests_in_object(test_object):
	var methods = test_object.get_method_list()
	
	# テストオブジェクトをシーンツリーに追加
	add_child(test_object)
	
	for method in methods:
		if method.name.begins_with("test_"):
			print("  🧪 " + method.name + "...")
			
			# setup メソッドがあれば実行
			if test_object.has_method("setup"):
				test_object.call("setup")
			
			# テスト実行
			var result = test_object.call(method.name)
			
			if result == true:
				test_results.passed += 1
				print("    ✓ Passed")
			else:
				test_results.failed += 1
				test_results.errors.append(method.name)
				print("    ✗ Failed")
			
			# teardown メソッドがあれば実行
			if test_object.has_method("teardown"):
				test_object.call("teardown")

func print_results():
	print("\n=== Test Results ===")
	print("Passed: " + str(test_results.passed))
	print("Failed: " + str(test_results.failed))
	
	if test_results.errors.size() > 0:
		print("\nFailed tests:")
		for error in test_results.errors:
			print("  - " + error)

# アサーション用のヘルパー関数
static func assert_true(condition: bool, message: String = "") -> bool:
	if not condition:
		if message != "":
			print("      Assertion failed: " + message)
		else:
			print("      Assertion failed: Expected true, got false")
		return false
	return true

static func assert_false(condition: bool, message: String = "") -> bool:
	if condition:
		if message != "":
			print("      Assertion failed: " + message)
		else:
			print("      Assertion failed: Expected false, got true")
		return false
	return true

static func assert_equal(actual, expected, message: String = "") -> bool:
	if actual != expected:
		if message != "":
			print("      Assertion failed: " + message)
		else:
			print("      Assertion failed: Expected " + str(expected) + ", got " + str(actual))
		return false
	return true

static func assert_not_null(value, message: String = "") -> bool:
	if value == null:
		if message != "":
			print("      Assertion failed: " + message)
		else:
			print("      Assertion failed: Expected non-null value")
		return false
	return true
