extends Node2D

func _ready() -> void:
	for score in ScoreServer.get_scores():
		$Gui/Scores.add_item( "Timpo: " + Global.format_time(score.time))
		$Gui/Scores.add_item(" | Puntos: " + str(absi(score.score)))
		$Gui/Scores.add_item(" | Movimientos: " + str(score.movements.size()))
		$Gui/Scores.add_item(" | Nombre: " + score.name)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Gui/main_screen.tscn")
