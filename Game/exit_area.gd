extends Area2D

var was_play := false

func _physics_process(delta: float) -> void:
	var bodies = get_overlapping_bodies()
	
	for body in bodies:
		if body.is_in_group("player") && body.is_moving:
			body.win = true
			play_sound()
			

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") && body.is_moving:
		body.win = true
		play_sound()

func play_sound():
	if !$Sound/Win.playing && !was_play:
		$Sound/Win.play()
		was_play = true
