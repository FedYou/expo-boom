extends Node2D

enum DIRECTION {
VERTICAL,
HORIZONTAL,
}

@export var direction: DIRECTION

@onready var sprite: Sprite2D = $Sprite
@onready var collision: CollisionShape2D = $Collision

var is_destroyed := false

func _ready() -> void:
	match direction:
		DIRECTION.VERTICAL:
			rotation = deg_to_rad(90)
		DIRECTION.HORIZONTAL:
			rotation = deg_to_rad(0)

func _on_body_entered(body: Node2D) -> void:
	if is_destroyed:
		return
	if body.is_in_group("player"):
		body.healt-=1
		is_destroyed = true
		collision.set_deferred("disabled", true)
		sprite.hide()
		queue_free()
