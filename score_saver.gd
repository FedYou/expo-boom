extends Node


const SAVE_PATH = "user://scores.json"

var scores: Array[Dictionary] = []

func _ready() -> void:
	_load_scores()

func save_score(
	player_name: String,
	score: int,
	movements: Array[Player.DIRECTION],
	time: float
) -> void:
	var result: Dictionary = {
		"name": player_name,
		"score": score,
		"movements": movements.duplicate(),
		"time": time
	}

	scores.append(result)

	_save_to_file()

func _save_to_file():
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)

	if file == null:
		push_error("Error al guardar los scores: " + str(FileAccess.get_open_error()))
		return

	file.store_string(JSON.stringify(scores, "\t"))


func _load_scores() -> void:
	if !FileAccess.file_exists(SAVE_PATH):
		scores.clear()
		return

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)

	if file == null:
		push_error("Error al leer: " + str(FileAccess.get_open_error()))
		return

	var data = JSON.parse_string(file.get_as_text())

	if !data is Array:
		push_error("El archivo no es valido")
		return

	scores.clear()

	for result in data:
		if result is Dictionary:
			scores.append(result)

func clear_scores() -> void:
	scores.clear()
	_save_to_file()

func get_scores_len() -> int:
	return scores.size()

func get_score(index: int) -> Dictionary:
	if index < 0 or index >= scores.size():
		return {}

	return scores[index]

func get_scores() -> Array:
	var scores = scores.duplicate()
	
	scores.sort_custom(
	func(a: Dictionary, b: Dictionary) -> bool:
		if a["score"] == b["score"]:
			return a["time"] < b["time"]
		return a["score"] > b["score"]
	)
	
	return scores

func get_score_position(
	score: int,
	time: float
) -> int:
	var sorted_scores := get_scores()

	for i in range(sorted_scores.size()):
		var current: Dictionary = sorted_scores[i]

		if score > current["score"]:
			return i + 1

		if score == current["score"] and time < current["time"]:
			return i + 1

	return sorted_scores.size() + 1
