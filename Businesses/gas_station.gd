extends Node2D
@onready var raycast: RayCast2D = $RayCast

var was_visited := false

func _physics_process(_delta: float) -> void:
	if !raycast.is_colliding() || was_visited:
		return

	var collider := raycast.get_collider()

	if collider is Node2D && collider.is_in_group("player"):
		if collider.is_moving:
			collider.must_wait=true
			was_visited = true
		else:
			was_visited = true
			collider.must_wait=true
		
