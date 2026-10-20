class_name Player
extends CharacterBody2D

enum DIRECTION {
	UP,
	DOWN,
	LEFT,
	RIGHT
}

@export var direction: DIRECTION
const SPEED = 200.0
const MOVE_TIME = 0.5
var is_moving := false


func _ready() -> void:
	_update_positions()

func execute_pending_moves(pending_moves: Array[DIRECTION]) -> void:
	if is_moving:
		return
	is_moving = true

	for move in pending_moves:
		direction = move
		match move:
			DIRECTION.UP:
				velocity.y = -SPEED
			DIRECTION.DOWN:
				velocity.y = SPEED
			DIRECTION.LEFT:
				velocity.x = -SPEED
			DIRECTION.RIGHT:
				velocity.x = SPEED

		var elapsed := 0.0
		while elapsed < MOVE_TIME:
			await get_tree().physics_frame
			move_and_slide()          # se en cada frame
			elapsed += get_physics_process_delta_time()
			_update_positions()

		velocity = Vector2.ZERO       # el player SE DETIENE al terminar la acción

	is_moving = false


func _update_positions()-> void:
	match direction:
		DIRECTION.UP, DIRECTION.DOWN:
			$Collision.rotation = deg_to_rad(0)
		DIRECTION.LEFT, DIRECTION.RIGHT:
			$Collision.rotation = deg_to_rad(90)
