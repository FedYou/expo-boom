extends Area2D

@onready var sprite = $Sprite
@onready var collison = $Collision

var fade_duration := 1.5

var is_destroy = false

func _physics_process(delta) -> void:
	if is_destroy:
		return

	await get_tree().physics_frame

	for area in get_overlapping_areas():
		if area.is_in_group("light"):
			sprite.visible = false
			collison.set_deferred("disabled", true)
			is_destroy = true
		elif area.is_in_group("player"):
			sprite.visible = false

func _on_body_entered(body: Node2D) -> void:
	if is_destroy:
		return

	if body.is_in_group("player"):
		var tween = create_tween()
		tween.tween_property(
			sprite,
			"modulate:a",
			0.0,
			fade_duration
		)


func _on_body_exited(body: Node2D) -> void:
	if is_destroy:
		return

	if body.is_in_group("player"):
		var tween = create_tween()
		tween.tween_property(
			sprite,
			"modulate:a",
			1.0,
			fade_duration
		)
