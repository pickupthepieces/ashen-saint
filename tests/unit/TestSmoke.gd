extends RefCounted

func run() -> Array[String]:
	var failures: Array[String] = []
	if 1 + 1 != 2:
		failures.append("basic arithmetic failed")
	return failures
