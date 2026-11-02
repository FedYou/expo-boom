extends Node2D

enum DIRECTION{
	LEFT,
	RIGHT
}

@export var direction : DIRECTION = DIRECTION.RIGHT

@onready var sprite = $Sprite
@onready var light = $Light
@onready var collision = $Collision

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if direction == DIRECTION.LEFT:
		$Sprite.flip_h = true
		$Light.position = Vector2(-12, $Light.position.y)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		collision.set_deferred("disabled", true)
		light.enabled = false
		sprite.play("breakup")
		$Sound/Breaking.play()


func _on_sprite_animation_finished() -> void:
	if sprite.animation == "breakup":
		sprite.play("break")
