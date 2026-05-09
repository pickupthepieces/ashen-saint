extends SceneTree

const TEST_DIR := "res://tests/unit"

func _init() -> void:
	var failures: Array[String] = []
	var files := DirAccess.get_files_at(TEST_DIR)

	for file_name in files:
		if not file_name.begins_with("Test") or not file_name.ends_with(".gd"):
			continue

		var script := load(TEST_DIR + "/" + file_name)
		var test = script.new()
		if not test.has_method("run"):
			failures.append("%s has no run() method" % file_name)
			continue

		var result = test.run()
		for failure in result:
			failures.append("%s: %s" % [file_name, failure])

	for failure in failures:
		push_error(failure)

	print("Test summary: %d failures" % failures.size())
	quit(1 if failures.size() > 0 else 0)
