class_name Screen
extends Node

@export var transition_duration : float
@export var background: ColorRect


func fade_out()-> void:
	background.color = "#000000"
	await Utils.fade_out(background, transition_duration)

func fade_in()-> void:
	background.color = "#000000"
	await Utils.fade_in(background, transition_duration)
