extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for score in ScoreServer.get_scores():
		$Gui/Scores.add_item( "Timpo: " + str(absi(score.time)))
		$Gui/Scores.add_item(" | Puntos: " + str(absi(score.score)))
		$Gui/Scores.add_item(" | Movimientos: " + str(score.movements.size()))
		$Gui/Scores.add_item(" | Nombre: " + score.name)
		#$GUI/Scores.add_item(_get_content_item(score))

func _get_content_item(score: Dictionary) -> String:
	return "Timpo " + str(score.time) + " | Puntos " + str(score.score) + " | Movimientos " +  str(score.movements.size()) + " | Nombre " + score.name


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Gui/main_screen.tscn")
