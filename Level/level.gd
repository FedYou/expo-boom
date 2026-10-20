extends Node2D

@onready var PLAYER = $Player
@onready var PENDING_MOVES = $CanvasLayer/PendingMoves
@onready var EXECUTED_MOVES = $CanvasLayer/ExecutedMoves

var executed_moves :Array[Player.DIRECTION] = []
var pending_moves: Array[Player.DIRECTION] = []

func _ready() -> void:
	_refresh_ui_move_lists()

func _refresh_ui_move_lists() -> void:
	_refresh_ui_executed_moves()
	_refresh_ui_pending_moves()

func _refresh_ui_executed_moves() -> void:
	EXECUTED_MOVES.clear()
	for move in executed_moves:
		EXECUTED_MOVES.add_item(_get_content_item(move))

func _refresh_ui_pending_moves() -> void:
	PENDING_MOVES.clear()
	for move in pending_moves:
		PENDING_MOVES.add_item(_get_content_item(move))

func _get_content_item(move: Player.DIRECTION) -> String:
	match move:
		Player.DIRECTION.UP:
			return "UP"
		Player.DIRECTION.DOWN:
			return "DOWN"
		Player.DIRECTION.LEFT:
			return "LEFT"
	return "RIGHT"


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
	executed_moves.append_array(pending_moves)
	
	PLAYER.execute_pending_moves(pending_moves.duplicate())
	pending_moves.clear()
	
	_refresh_ui_move_lists()
