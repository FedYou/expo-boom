extends Node

func format_time(seconds: float) -> String:
	var total_milliseconds := int(seconds * 1000.0)

	var minutes := total_milliseconds / 60000
	var remaining_seconds := (total_milliseconds / 1000) % 60
	var milliseconds := total_milliseconds % 1000

	return "%02d:%02d.%03d" % [
		minutes,
		remaining_seconds,
		milliseconds
	]
