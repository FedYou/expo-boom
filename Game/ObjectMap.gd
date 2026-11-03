class_name ObjectMap
extends Area2D

@export var collision : CollisionShape2D
@export var sprite: AnimatedSprite2D
@export var collision_sound: AudioStreamPlayer2D

@export_group("Features")
@export var instakill: bool
@export var damage: int = 1
@export var remove_points: int
@export var add_points: int = 0
@export var add_movements: int = 0
@export var must_wait: float = 0.0

enum DIRECTION {
VERTICAL,
HORIZONTAL,
}

@export var direction: DIRECTION = DIRECTION.HORIZONTAL

func _ready() -> void:
	sprite.play("default")
	sprite.animation_finished.connect(_on_sprite_animation_finished)
	body_entered.connect(on_detect)
	match direction:
		DIRECTION.VERTICAL:
			rotation = deg_to_rad(90)
		DIRECTION.HORIZONTAL:
			rotation = deg_to_rad(0)

func _physics_process(delta: float) -> void:
	var bodies = get_overlapping_bodies()
	
	for body in bodies:
		on_detect(body)

func on_detect(body: Node2D) -> void:
	if body.is_in_group("player") && body.is_moving:
		if instakill:
			body.remove_all_points()
			body.is_alive = false
			body.start_explosion()
		else:
			body.remove_points(remove_points)
			body.add_points(add_points)
			body.add_movements(add_movements)
			body.healt-=damage
			
		collision.set_deferred("disabled", true)
		collision.free()

		if collision_sound:
			collision_sound.play()
		
		if sprite.sprite_frames.get_animation_names().has("breakup"):
			sprite.play("breakup")
		body.must_wait = must_wait
		

func _on_sprite_animation_finished() -> void:
	if sprite.animation == "breakup":
		if sprite.sprite_frames.get_animation_names().has("break"):
			sprite.play("break")
