extends Area2D

func _physics_process(delta: float) -> void:
	var bodies = get_overlapping_bodies()
	
	for body in bodies:
		if body.is_in_group("player") && body.is_moving:
			body.win = true

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") && body.is_moving:
		body.win = true
