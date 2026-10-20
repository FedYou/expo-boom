extends CharacterBody2D

const SPEED = 300.0

func _physics_process(delta: float) -> void:
	var direction_y := Input.get_axis("ui_up", "ui_down")
	var direction_x := Input.get_axis("ui_left", "ui_right")
	
	## La funcion move_toward cambia la cantidad de un inical valor hasta llegar a un 
	## valor deseado si sobrepasarlo.
	##  move_toward(<valor inical>, <valor a llegar>, <cantidad a reducir>)
	
	if direction_x:
		velocity.x = direction_x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if direction_y:
		velocity.y = direction_y * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()
