class_name Player
extends CharacterBody2D

enum DIRECTION {
	UP,
	DOWN,
	LEFT,
	RIGHT
}

@export var direction: DIRECTION
@onready var SPRITE = $Sprite

const SPEED = 200.0
const MOVE_TIME = 0.25
const CELL = 32.0
const REBOUND = 10.0

var is_moving := false
var is_colliding:= false


func _ready() -> void:
	_update_positions()



func execute_pending_moves(pending_moves: Array[DIRECTION]) -> void:
	if is_moving || is_colliding:
		return
	is_moving = true


	for index in range(pending_moves.size()):
		var move = pending_moves[index]
		direction = move
		_update_positions()
		
		var is_next_equal := false
		
		if pending_moves.size() - 1 > index:
			if move == pending_moves[index +1 ]:
				is_next_equal = true
		else:
			match move:
				DIRECTION.UP:
					if $Vertical/RayTop.is_colliding():
						is_next_equal = true
				DIRECTION.DOWN:
					if $Vertical/RayDown.is_colliding():
						is_next_equal = true
				DIRECTION.LEFT:
					if $Horizontal/RayLeft.is_colliding():
						is_next_equal = true
				DIRECTION.RIGHT:
					if $Horizontal/RayRight.is_colliding():
						is_next_equal = true
			
		
		var target_position = 0
		match move:
			DIRECTION.UP:
				velocity.y = -SPEED
				target_position = position.y - CELL
			DIRECTION.DOWN:
				velocity.y = SPEED
				target_position = position.y + CELL
			DIRECTION.LEFT:
				velocity.x = -SPEED
				target_position = position.x - CELL
			DIRECTION.RIGHT:
				velocity.x = SPEED
				target_position = position.x + CELL

		var elapsed := 0.0
	
		while elapsed < MOVE_TIME:
			await get_tree().physics_frame
			if !is_next_equal:
				match move:
					DIRECTION.UP:
						if $Vertical/RayTop.is_colliding():
							break
					DIRECTION.DOWN:
						if $Vertical/RayDown.is_colliding():
							break
					DIRECTION.LEFT:
						if $Horizontal/RayLeft.is_colliding():
							break
					DIRECTION.RIGHT:
						if $Horizontal/RayRight.is_colliding():
							break
			for i in get_slide_collision_count():
				var collision = get_slide_collision(i)
				var normal = collision.get_normal()

				if normal.x > 0 && move == DIRECTION.LEFT:
					is_colliding = true
				elif normal.x < 0 && move == DIRECTION.RIGHT:
					is_colliding = true
				elif normal.y > 0 && move == DIRECTION.DOWN:
					is_colliding = true
				elif normal.y < 0 && move == DIRECTION.UP:
					is_colliding = true
			
			if is_colliding:
				match move:
					DIRECTION.UP:
						velocity.y = REBOUND
					DIRECTION.DOWN:
						velocity.y = -REBOUND
					DIRECTION.LEFT:
						velocity.x = REBOUND
					DIRECTION.RIGHT:
						velocity.x = -REBOUND
				is_colliding=false
				move_and_slide()
			
			match move:
				DIRECTION.UP:
					if position.y <= target_position:
						velocity = Vector2.ZERO
						move_and_slide()
						break
				DIRECTION.DOWN:
					if position.y >= target_position:
						velocity = Vector2.ZERO
						move_and_slide()
						break
				DIRECTION.LEFT:
					if position.x <= target_position:
						velocity = Vector2.ZERO
						move_and_slide()
						break
				DIRECTION.RIGHT:
					if position.x >= target_position:
						velocity = Vector2.ZERO
						move_and_slide()
						break

			elapsed += get_physics_process_delta_time()
			move_and_slide()


		velocity = Vector2.ZERO       # el player SE DETIENE
		if is_colliding:
			is_colliding = false

	is_moving = false


func _update_positions()-> void:
	match direction:
		DIRECTION.UP, DIRECTION.DOWN:
			$Collision.rotation = deg_to_rad(0)
			SPRITE.rotation = deg_to_rad(0)
		DIRECTION.LEFT, DIRECTION.RIGHT:
			$Collision.rotation = deg_to_rad(90)
			SPRITE.rotation = deg_to_rad(90)

	match direction:
		DIRECTION.UP:
			SPRITE.flip_v = false
		DIRECTION.DOWN:
			SPRITE.flip_v = true
		DIRECTION.LEFT:
			SPRITE.flip_v = true 
		DIRECTION.RIGHT:
			SPRITE.flip_v = false
