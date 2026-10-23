extends Node2D

func _ready() -> void:
	var scores = ScoreServer.get_scores()
	
	scores.sort_custom(
	func(a: Dictionary, b: Dictionary) -> bool:
		if a["score"] == b["score"]:
			return a["time"] < b["time"]
		return a["score"] > b["score"]
)

	for score in scores:
		$Gui/Scores.add_item( "Timpo: " + Global.format_time(score.time))
		$Gui/Scores.add_item(" | Puntos: " + str(absi(score.score)))
		$Gui/Scores.add_item(" | Movimientos: " + str(score.movements.size()))
		$Gui/Scores.add_item(" | Nombre: " + score.name)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Gui/main_screen.tscn")
