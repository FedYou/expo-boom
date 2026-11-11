extends BaseButton

@export var parent: Node
@export var sound_hover: AudioStream = preload("res://Assets/Sounds/Ui/hover.ogg")
@export var sound_pressed: AudioStream = preload("res://Assets/Sounds/Ui/pressed.ogg")
@export var enable_double_clicking : bool = false

var tween: Tween

@onready var sound: Dictionary = {
	"hover": AudioStreamPlayer2D.new(),
	"pressed": AudioStreamPlayer2D.new()
}

func _ready() -> void:
	pressed.connect(on_pressed)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	sound.hover.stream = sound_hover
	sound.pressed.stream = sound_pressed

	add_child(sound.hover)
	add_child(sound.pressed)


func animate_node(node: Control, target_scale: Vector2) -> void:
	node.pivot_offset = node.size / 2.0

	if tween and tween.is_running():
		tween.kill()

	tween = create_tween()
	tween.set_trans(Tween.TRANS_BACK)
	tween.set_ease(Tween.EASE_OUT)

	tween.tween_property(node, "scale", target_scale, 0.15)

func on_pressed() -> void:
	sound.pressed.play()
	if !enable_double_clicking:
		disabled = true
		
		await get_tree().create_timer(0.5).timeout
		
		disabled = false

func _on_mouse_entered() -> void:
	if parent && parent.modulate.a < 1.0:
		return
	
	if disabled:
		return
	
	animate_node(self,Vector2(1.1,1.1))
	sound.hover.play()

func _on_mouse_exited() -> void:
	if parent && parent.modulate.a < 1.0:
		return
	
	if disabled:
		return
		
	animate_node(self,Vector2.ONE)
