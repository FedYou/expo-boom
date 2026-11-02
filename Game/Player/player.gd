class_name Player
extends CharacterBody2D

enum DIRECTION {
	UP,
	DOWN,
	LEFT,
	RIGHT
}

@onready var sprite = $Sprite
@onready var light = $Light
@onready var light_vertical_position = light.position

@onready var sound: Dictionary = {
	"moving": $Sound/Moving,
	"stop": $Sound/Stop,
	"explosion": $Sound/Explosion,
	"collision": $Sound/Collision
}

@export var max_healt = 3
@export var max_movements = 10
@export var direction: DIRECTION

const MOVE_TIME = 0.25
const CELL = 32.0
const GRID_OFFSET := Vector2(16, 16)
const REBOUND = 10.0
const REBOUND_TIME = 0.1
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

var shake_material: ShaderMaterial

func _ready() -> void:
	update_positions()
	shake_material = sprite.material as ShaderMaterial
	stop_shake()

func _process(delta: float) -> void:
	if must_wait > 0:
		await get_tree().create_timer(must_wait).timeout
		must_wait = 0

func start_shake() -> void:
	sprite.material = shake_material

func stop_shake() -> void:
	sprite.material = null
	

func start_explosion()-> void:
	sprite.play("explosion")
	sound.explosion.play()
	light.hide()

func _direction_vector(m: DIRECTION) -> Vector2:
	match m:
		DIRECTION.UP: return Vector2.UP
		DIRECTION.DOWN: return Vector2.DOWN
		DIRECTION.LEFT: return Vector2.LEFT
		_: return Vector2.RIGHT

# true si hay una pared dentro de la próxima celda
func _is_blocked_ahead(m: DIRECTION) -> bool:
	return test_move(global_transform, _direction_vector(m) * CELL)

## Perimite ubicar la posicion del jugador en la mitad de cada celda altes de moverse
func _snap_to_grid() -> void:
	position = ((position - GRID_OFFSET) / CELL).round() * CELL + GRID_OFFSET



func execute_pending_moves(pending_moves: Array[DIRECTION]) -> Array[DIRECTION]:
	var executed_moves: Array[DIRECTION] = []

	if lost|| win || is_moving || !is_alive || must_wait:
		return executed_moves

	is_moving = true
	sound.moving.play()
	velocity = Vector2.ZERO
	start_shake()
	
	## Limpia la detección de los coliciones anterior
	move_and_slide()
	
	for index in range(pending_moves.size()):
		if win || lost:
			break
		
		var move = pending_moves[index]
		direction = move

		update_positions()
		_snap_to_grid()
		
		var start_position := position
		var direction_move := _direction_vector(move)
		var target_position := start_position + direction_move * CELL
		var elapsed := 0.0
		var hit_this_move := false

		while elapsed < MOVE_TIME:
			await get_tree().physics_frame
			if must_wait > 0:
				$Light/Back.energy = 2.0
				Utils.stop_sound_fade(sound.moving,0.5)
				sound.stop.play()
				stop_shake()
				await get_tree().create_timer(must_wait).timeout
				must_wait = 0
				$Light/Back.energy = 1.0
				sound.moving.play()
				start_shake()

			var dt := get_physics_process_delta_time()
			var remaining := (target_position - position).dot(direction_move)

			if remaining <= 0.01:
				break

			# Velocidad limitada en el último tramo frena justo en el objetivo
			velocity = direction_move * minf(SPEED, remaining / dt)
			move_and_slide()

			# Detección de choque contra algo que se oponga al movimiento
			for i in get_slide_collision_count():
				var normal := get_slide_collision(i).get_normal()
				if normal.dot(direction_move) < -0.5:
					hit_this_move = true

			if hit_this_move:
				break

			elapsed += dt
		## ----- ##
		if hit_this_move:
			healt -= 1
			sound.collision.play()
			remove_points(HIT_POINTS)
			if healt <= 0:
				is_alive = false
				start_explosion()
				break
			# Rebote: vuelve a la celda de origen, así nunca se desfasa
			var tween := create_tween()
			tween.tween_property(self, "position", start_position, REBOUND_TIME)
			await tween.finished
		else:
			position = target_position  # aterriza exacto en la celda

		movements_count += 1
		executed_moves.push_back(move)

		if movements_count >= max_movements && !win:
			lost = true
			start_explosion()
			break

	is_moving = false
	stop_shake()
	if sound.moving.playing:
		Utils.stop_sound_fade(sound.moving, 0.5)
		sound.stop.play()

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
			sprite.rotation = deg_to_rad(0)
			light.rotation = deg_to_rad(0)
			light.position = light_vertical_position
		DIRECTION.RIGHT:
			$Collision.rotation = deg_to_rad(90)
			sprite.rotation = deg_to_rad(90)
			light.rotation = deg_to_rad(90)
			light.position = Vector2(40,0)
		DIRECTION.DOWN:
			$Collision.rotation = deg_to_rad(0)
			sprite.rotation = deg_to_rad(0)
			light.rotation = deg_to_rad(180)
			light.position = Vector2(0,40)
		DIRECTION.LEFT:
			$Collision.rotation = deg_to_rad(90)
			sprite.rotation = deg_to_rad(90)
			light.rotation = deg_to_rad(-90)
			light.position = Vector2(-40,0)

	match direction:
		DIRECTION.UP:
			sprite.flip_v = false
		DIRECTION.DOWN:
			sprite.flip_v = true
		DIRECTION.LEFT:
			sprite.flip_v = true 
		DIRECTION.RIGHT:
			sprite.flip_v = false

func reset()->void:
	healt = max_healt
	score = 0
	is_moving = false
	is_alive = true
	must_wait = 0.0
	win = false
	lost = false
	movements_count = 0
	sprite.play("default")
	light.show()
