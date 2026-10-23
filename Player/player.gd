class_name Player
extends CharacterBody2D

enum DIRECTION {
	UP,
	DOWN,
	LEFT,
	RIGHT
}

@export var max_healt = 3
@export var max_movements = 10
@export var direction: DIRECTION
@onready var SPRITE = $Sprite

const SPEED = 200.0
const MOVE_TIME = 0.25
const MUST_WAIT_TIME = 2.0
const CELL = 32.0
const REBOUND = 10.0
const HIT_POINTS = 10

var healt = max_healt
var score : int = 0
var is_moving := false
var is_alive := true
var must_wait:= false
var win := false
var lost :=false
var movements_count : int = 0

func _ready() -> void:
	_update_positions()

func _process(delta: float) -> void:
	if must_wait:
		await get_tree().create_timer(MUST_WAIT_TIME).timeout
		must_wait = false


func execute_pending_moves(pending_moves: Array[DIRECTION], executed_moves: Array[DIRECTION]) -> void:
	if lost|| win || is_moving || !is_alive || must_wait:
		return
	is_moving = true


	for index in range(pending_moves.size()):
		if win || lost:
			break
		
		var move = pending_moves[index]
		direction = move

		_update_positions()
		
		var should_continue := false
		
		if pending_moves.size() - 1 > index:
			if move == pending_moves[index +1 ]:
				should_continue = true

		if !should_continue:
			match move:
				DIRECTION.UP:
					if $Vertical/RayTop.is_colliding():
						should_continue = true
				DIRECTION.DOWN:
					if $Vertical/RayDown.is_colliding():
						should_continue = true
				DIRECTION.LEFT:
					if $Horizontal/RayLeft.is_colliding():
						should_continue = true
				DIRECTION.RIGHT:
					if $Horizontal/RayRight.is_colliding():
						should_continue = true
			
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
			if must_wait:
				await get_tree().create_timer(MUST_WAIT_TIME).timeout
				must_wait = false
				
			if !should_continue:
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
			
			var hit := false
			
			for i in get_slide_collision_count():
				var collision = get_slide_collision(i)
				var normal = collision.get_normal()

				if normal.x > 0 && move == DIRECTION.LEFT:
					hit = true
				elif normal.x < 0 && move == DIRECTION.RIGHT:
					hit = true
				elif normal.y < 0 && move == DIRECTION.DOWN:
					hit = true
				elif normal.y > 0 && move == DIRECTION.UP:
					hit = true
			
			if hit:
				healt-=1
				remove_points(HIT_POINTS)
				if healt <= 0:
					is_alive = false
					break
				
				match move:
					DIRECTION.UP:
						velocity.y = REBOUND
					DIRECTION.DOWN:
						velocity.y = -REBOUND
					DIRECTION.LEFT:
						velocity.x = REBOUND
					DIRECTION.RIGHT:
						velocity.x = -REBOUND
				hit=false
				move_and_slide()
				continue

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
		
		movements_count+=1
		executed_moves.push_back(move)
		
		if movements_count >= max_movements && !win:
			lost = true
			break
	is_moving = false

func add_movements(movements: int) -> void:
	max_movements += randi_range(movements/2, movements)

func add_points(points: int) -> void:
	score += randi_range(1, points)

func remove_points(points: int) -> void:
	score = maxi(0, score -  randi_range(1, points))

func remove_all_points() -> void:
	score = 0


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
