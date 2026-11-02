extends Area2D

@onready var sprite: Sprite2D = $Sprite
@onready var collision: CollisionShape2D = $Collision

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.remove_all_points()
		body.healt = 0
		body.is_alive = false
		
		
		collision.set_deferred("disabled", true)
