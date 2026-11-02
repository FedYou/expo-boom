extends Area2D

@onready var sprite: Sprite2D = $Sprite
@onready var collision: CollisionShape2D = $Collision

func _physics_process(delta: float) -> void:
	var bodies = get_overlapping_bodies()
	
	for body in bodies:
		if body.is_in_group("player") && body.is_moving:
			body.is_alive = false
			body.start_explosion()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") && body.is_moving:
		body.remove_all_points()
		body.healt = 0
		body.is_alive = false
		body.start_explosion()
		
		collision.set_deferred("disabled", true)
