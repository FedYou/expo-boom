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
@onready var LIGHT = $Light
@onready var LIGHT_VERTICAL_POSITION = LIGHT.position


const MOVE_TIME = 0.25
const CELL = 32.0
const REBOUND = 10.0
const HIT_POINTS = 10
const SPEED = 200.0

var healt = max_healt
var score : int = 0
var is_moving := false
var is_alive := true
var must_wait:= 0.0
var win := false
var lost :=false
var movements_count : int = 0

func _ready() -> void:
	update_positions()

func _process(delta: float) -> void:
	if must_wait > 0:
		await get_tree().create_timer(must_wait).timeout
		must_wait = 0


func execute_pending_moves(pending_moves: Array[DIRECTION]) -> Array[DIRECTION]:
	var executed_moves: Array[DIRECTION] = []

	if lost|| win || is_moving || !is_alive || must_wait:
		return executed_moves

	is_moving = true

	for index in range(pending_moves.size()):
		if win || lost:
			break
		
		var move = pending_moves[index]
		direction = move

		update_positions()
		
		var should_continue := false
		
		if pending_moves.size() - 1 > index:
			if move == pending_moves[index +1 ]:
				should_continue = true

		if !should_continue:
			match move:
				DIRECTION.UP:
					if $Vertical/RayTop.is_colliding():
						should_continue = true
					elif $Vertical/RayDown.is_colliding():
						should_continue = true
				DIRECTION.DOWN:
					if $Vertical/RayDown.is_colliding():
						should_continue = true
					elif $Vertical/RayTop.is_colliding():
						should_continue = true
				DIRECTION.LEFT:
					if $Horizontal/RayLeft.is_colliding():
						should_continue = true
					elif $Horizontal/RayRight.is_colliding():
						should_continue = true
				DIRECTION.RIGHT:
					if $Horizontal/RayRight.is_colliding():
						should_continue = true
					elif $Horizontal/RayLeft.is_colliding():
						should_continue = true

		var target_position := 0.0
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
			if must_wait > 0:
				$Light/Back.energy = 2.0
				await get_tree().create_timer(must_wait).timeout
				must_wait = 0
				$Light/Back.energy = 1.0
			
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
	return executed_moves

func add_movements(movements: int) -> void:
	max_movements += randi_range(movements/2, movements)

func add_points(points: int) -> void:
	score += randi_range(1, points)

func remove_points(points: int) -> void:
	score = maxi(0, score -  randi_range(1, points))
	$Light/Back.energy = 2.0
	$Light/Front.energy = 0.0
	await get_tree().create_timer(0.15).timeout
	$Light/Front.energy = 0.5
	await get_tree().create_timer(0.10).timeout
	$Light/Back.energy = 1.0
	$Light/Front.energy = 1.0

func remove_all_points() -> void:
	score = 0

func update_positions()-> void:
	match direction:
		DIRECTION.UP:
			$Collision.rotation = deg_to_rad(0)
			SPRITE.rotation = deg_to_rad(0)
			LIGHT.rotation = deg_to_rad(0)
			LIGHT.position = LIGHT_VERTICAL_POSITION
		DIRECTION.RIGHT:
			$Collision.rotation = deg_to_rad(90)
			SPRITE.rotation = deg_to_rad(90)
			LIGHT.rotation = deg_to_rad(90)
			LIGHT.position = Vector2(40,0)
		DIRECTION.DOWN:
			$Collision.rotation = deg_to_rad(0)
			SPRITE.rotation = deg_to_rad(0)
			LIGHT.rotation = deg_to_rad(180)
			LIGHT.position = Vector2(0,40)
		DIRECTION.LEFT:
			$Collision.rotation = deg_to_rad(90)
			SPRITE.rotation = deg_to_rad(90)
			LIGHT.rotation = deg_to_rad(-90)
			LIGHT.position = Vector2(-40,0)

	match direction:
		DIRECTION.UP:
			SPRITE.flip_v = false
		DIRECTION.DOWN:
			SPRITE.flip_v = true
		DIRECTION.LEFT:
			SPRITE.flip_v = true 
		DIRECTION.RIGHT:
			SPRITE.flip_v = false

func reset()->void:
	healt = max_healt
	score = 0
	is_moving = false
	is_alive = true
	must_wait = 0.0
	win = false
	lost = false
	movements_count = 0
