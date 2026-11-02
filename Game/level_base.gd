class_name LevelBase
extends Node2D

@export_group("Player")
@export var player: Marker2D
@export var player_direction: Player.DIRECTION
@export var max_movements = 10

@export_group("Map")
@export var camara_limits: ColorRect
@export var ambient_sound: AudioStreamPlayer2D

var executed_moves :Array[Player.DIRECTION] = []
var pending_moves: Array[Player.DIRECTION] = []

var start_time: int = 0 
var end_time: int = 0

func _ready() -> void:
	start_time = Time.get_ticks_msec()
	camara_limits.color = "#ffffff00"
	ambient_sound.play()

func finish() -> void:
	if end_time == 0:
		end_time = Time.get_ticks_msec()

func get_current_time()-> float:
	return (Time.get_ticks_msec() - start_time) / 1000.0

func get_time() -> float:
	var stop := end_time if end_time > 0 else Time.get_ticks_msec()
	return (stop - start_time) / 1000.0

func reset():
	executed_moves.clear()
	pending_moves.clear()
	start_time = Time.get_ticks_msec()
	end_time = 0
