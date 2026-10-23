extends Node2D

@onready var PLAYER = $Player
@onready var PLAY_BT = $Hub/Actions/Margin/Grid/Play
@onready var PENDING_MOVES = $Hub/ScrollPendingMoves/Container
@onready var EXECUTED_MOVES = $Hub/ScrollExecutedMoves/Container

var executed_moves :Array[Player.DIRECTION] = []
var pending_moves: Array[Player.DIRECTION] = []

func _ready() -> void:
	_refresh_ui_move_lists()
	_update_play_bt_state()
	_update_healt_ui()
	_update_score_ui()

func _process(delta: float) -> void:
	_update_play_bt_state()
	_update_healt_ui()
	_update_score_ui()
	if !PLAYER.is_alive:
		$Hub.hide()
		$GameOverScreen.show()

func _refresh_ui_move_lists() -> void:
	_refresh_ui_executed_moves()
	_refresh_ui_pending_moves()

func _refresh_ui_executed_moves() -> void:
	for item in EXECUTED_MOVES.get_children():
		item.queue_free()
	
	for move in executed_moves:
		EXECUTED_MOVES.add_child(_get_content_item(move))

func _refresh_ui_pending_moves() -> void:
	for item in PENDING_MOVES.get_children():
		item.queue_free()
	
	for move in pending_moves:
		
		PENDING_MOVES.add_child(_get_content_item(move))


func _get_content_item(move: Player.DIRECTION) -> TextureRect:
	var item := TextureRect.new()

	item.custom_minimum_size = Vector2(32, 32)
	item.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	item.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	match move:
		Player.DIRECTION.UP:
			item.texture = preload("res://Assets/UI/MoveIcons/Up.png")
		Player.DIRECTION.DOWN:
			item.texture = preload("res://Assets/UI/MoveIcons/Down.png")
		Player.DIRECTION.LEFT:
			item.texture = preload("res://Assets/UI/MoveIcons/Left.png")
		Player.DIRECTION.RIGHT:
			item.texture = preload("res://Assets/UI/MoveIcons/Right.png")

	return item

func _update_play_bt_state():
	if PLAYER.is_moving || pending_moves.is_empty():
		PLAY_BT.disabled = true
	else:
		PLAY_BT.disabled = false

func _update_healt_ui():
	if PLAYER.is_alive:
		match PLAYER.healt:
			1: 
				$Hub/MarginHeart/Heart/Heart1.texture = preload("res://Assets/UI/Heart.png")
				$Hub/MarginHeart/Heart/Heart2.texture = preload("res://Assets/UI/HeartVoid.png")
				$Hub/MarginHeart/Heart/Heart3.texture = preload("res://Assets/UI/HeartVoid.png")
			2:
				$Hub/MarginHeart/Heart/Heart1.texture = preload("res://Assets/UI/Heart.png")
				$Hub/MarginHeart/Heart/Heart2.texture = preload("res://Assets/UI/Heart.png")
				$Hub/MarginHeart/Heart/Heart3.texture = preload("res://Assets/UI/HeartVoid.png")
			3:
				$Hub/MarginHeart/Heart/Heart1.texture = preload("res://Assets/UI/Heart.png")
				$Hub/MarginHeart/Heart/Heart2.texture = preload("res://Assets/UI/Heart.png")
				$Hub/MarginHeart/Heart/Heart3.texture = preload("res://Assets/UI/Heart.png")

func _update_score_ui():
	$Hub/MarginScore/Grid/Label.text = "Puntos " + str(PLAYER.score)

func _on_up_pressed() -> void:
	pending_moves.push_back(PLAYER.DIRECTION.UP)
	_refresh_ui_pending_moves()

func _on_down_pressed() -> void:
	pending_moves.push_back(PLAYER.DIRECTION.DOWN)
	_refresh_ui_pending_moves()

func _on_right_pressed() -> void:
	pending_moves.push_back(PLAYER.DIRECTION.RIGHT)
	_refresh_ui_pending_moves()

func _on_left_pressed() -> void:
	pending_moves.push_back(PLAYER.DIRECTION.LEFT)
	_refresh_ui_pending_moves()

func _on_play_pressed() -> void:
	if PLAYER.is_moving:
		return

	executed_moves.append_array(pending_moves)

	PLAYER.execute_pending_moves(pending_moves.duplicate())
	pending_moves.clear()
	
	_refresh_ui_move_lists()

func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()
