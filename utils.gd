extends Node

func format_time(seconds: float) -> String:
	var total_milliseconds := int(seconds * 1000.0)

	var minutes := total_milliseconds / 60000
	var remaining_seconds := (total_milliseconds / 1000) % 60
	var milliseconds := total_milliseconds % 1000

	return "%02d:%02d.%03d" % [
		minutes,
		remaining_seconds,
		milliseconds
	]

func move_camara_2d(camara: Camera2D, target: Vector2, target_zoom: Vector2, duration: float) -> void:
	var tween = create_tween().set_parallel(true)
	
	tween.tween_property(camara, "global_position", target,duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(camara, "zoom", target_zoom,duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	await  tween.finished
	await get_tree().create_timer(0.5).timeout

func fade_in(node: Control, duration: float = 0.5) -> void:
	node.modulate.a = 0.0
	node.visible = true

	var tween = create_tween()
	tween.tween_property(
		node,
		"modulate:a",
		1.0,
		duration
	)
	await tween.finished
	node.show()


func fade_out(node: Control, duration: float = 0.5) -> void:
	var tween = create_tween()

	tween.tween_property(
		node,
		"modulate:a",
		0.0,
		duration
	)

	await tween.finished
	node.visible = false
	node.hide()

func stop_sound_fade(audio: AudioStreamPlayer2D, duration: float = 1.0) -> void:
	if not audio.playing:
		return

	var tween := create_tween()

	tween.tween_property(
		audio,
		"volume_db",
		-80.0,
		duration
	)

	await tween.finished
	audio.stop()
	audio.volume_db = 0.0
