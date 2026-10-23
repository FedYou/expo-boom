extends Node2D


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Level/level.tscn")

func _on_score_pressed() -> void:
	get_tree().change_scene_to_file("res://Gui/scores_screen.tscn")

func _on_exit_pressed() -> void:
	get_tree().quit()
