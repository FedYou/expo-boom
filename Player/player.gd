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
var is_colliding:= false


func _ready() -> void:
	_update_positions()

func execute_pending_moves(pending_moves: Array[DIRECTION]) -> void:
	if is_moving || is_colliding:
		return
	is_moving = true

	for move in pending_moves:
		if is_colliding:
			is_moving = false
			break
		
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
			if is_on_ceiling() || is_on_floor() || is_on_wall():
				is_colliding=true
			
			if is_colliding:
				match move:
					DIRECTION.UP:
						velocity.y = 10
					DIRECTION.DOWN:
						velocity.y = -10
					DIRECTION.LEFT:
						velocity.x = 10
					DIRECTION.RIGHT:
						velocity.x = -10
			
			
			move_and_slide()
			elapsed += get_physics_process_delta_time()
			_update_positions()

		velocity = Vector2.ZERO       # el player SE DETIENE
		if is_colliding:
			is_colliding = false

	is_moving = false


func _update_positions()-> void:
	match direction:
		DIRECTION.UP, DIRECTION.DOWN:
			$Collision.rotation = deg_to_rad(0)
		DIRECTION.LEFT, DIRECTION.RIGHT:
			$Collision.rotation = deg_to_rad(90)
