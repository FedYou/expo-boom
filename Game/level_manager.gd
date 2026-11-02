class_name LevelManager
extends Node2D

@export var gui : CanvasLayer
@export var player : Player
@export var camara: Camera2D

var level : Dictionary
var level_packed: PackedScene
var level_instantiate: LevelBase


func _ready() -> void:
	_set_random_level()
	_load_level()
	_load_level_values()


func _set_random_level():
	level = LevelLoader.levels.pick_random()
	level_packed = load(level.path)

func _load_level():
	level_instantiate = level_packed.instantiate()
	add_child(level_instantiate)
	move_child(level_instantiate, 0)

func _load_level_values():
	## Cargar el nivel al gui
	gui.level = level_instantiate
	
	## Cargar los datos del player para el nivel
	player.max_movements = level_instantiate.max_movements
	player.position = level_instantiate.player.position
	player.direction = level_instantiate.player_direction
	
	## Actutaliza las posicions del player
	player.update_positions()
	
	## Carga los limetes de la camara
	camara.limit_right = level_instantiate.camara_limits.size.x
	camara.limit_bottom = level_instantiate.camara_limits.size.y
	camara.reset_smoothing()
	

func reload_level():
	level_instantiate.free()
	
	_load_level()
	
	player.reset()
	
	_load_level_values()

func reload_to_random_level():
	level_instantiate.free()
	
	_set_random_level()
	_load_level()
	
	player.reset()
	
	_load_level_values()
