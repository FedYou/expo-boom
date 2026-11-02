extends Screen

@export var player: Player
@export var level: LevelBase
@export var level_maneger: LevelManager

@onready var heart_1 = $Hub/Left/Box/Hearts/Heart1
@onready var heart_2 = $Hub/Left/Box/Hearts/Heart2
@onready var heart_3 = $Hub/Left/Box/Hearts/Heart3

var heart_texture = preload("res://Assets/Ui/Heart.png")
var heart_void_texture = preload("res://Assets/Ui/HeartVoid.png")

@onready var score_value = $Hub/Left/Box/Score/Value

@onready var movements_value = $Hub/Center/Movements/Value
@onready var time_value = $Hub/Center/Time/Value

@onready var moves_executed_box = $Hub/Moves/Executed/HBox
@onready var moves_executed_scroll = $Hub/Moves/Executed
@onready var moves_pending_box = $Hub/Moves/Pending/HBox
@onready var moves_pending_scroll = $Hub/Moves/Pending

var move_icon_up_texture = preload("res://Assets/Ui/MoveIcons/Up.png")
var move_icon_down_texture = preload("res://Assets/Ui/MoveIcons/Down.png")
var move_icon_left_texture = preload("res://Assets/Ui/MoveIcons/Left.png")
var move_icon_right_texture = preload("res://Assets/Ui/MoveIcons/Right.png")

@onready var bt_play = $Hub/Controls/Actions/HBox/Grid/Play
@onready var bt_up = $Hub/Controls/Actions/HBox/Grid/Up
@onready var bt_down = $Hub/Controls/Actions/HBox/Grid/Down
@onready var bt_left = $Hub/Controls/Actions/HBox/Grid/Left
@onready var bt_right = $Hub/Controls/Actions/HBox/Grid/Right

@onready var win_position = $GameWin/Center/VBox/MarginMessage/Center/Grid/PositionValue
@onready var win_score = $GameWin/Center/VBox/MarginMessage/Center/Grid/ScoreValue
@onready var win_movements = $GameWin/Center/VBox/MarginMessage/Center/Grid/MovementsValue
@onready var win_time = $GameWin/Center/VBox/MarginMessage/Center/Grid/TimeValue

@onready var win_input = $GameWin/Center/VBox/MarginInput/VBox/Input
@onready var win_input_label = $GameWin/Center/VBox/MarginInput/VBox/InputLabel

@onready var hub = $Hub
@onready var game_over = $GameOver
@onready var game_win = $GameWin

func _ready() -> void:
	_refresh_ui_move_lists()
	_update_buttons_state()
	_update_healt_ui()
	_update_score_ui()
	await fade_out()

func _process(_delta: float) -> void:
	_update_buttons_state()
	_update_healt_ui()
	_update_score_ui()
	_update_time_ui()
	_update_movements_ui()
	_refresh_ui_move_lists()
	
	if player.lost:
		hub.hide()
		game_over.show()
		return
	
	if !player.is_alive && !player.win:
		hub.hide()
		game_over.show()
		return
	
	if player.win:
		hub.hide()
		game_win.show()
		level.finish()
		_update_win_screen_ui()
		return
	
	hub.show()
	game_win.hide()
	game_over.hide()

func _refresh_ui_move_lists() -> void:
	_refresh_ui_executed_moves()
	_refresh_ui_pending_moves()

func _refresh_ui_executed_moves() -> void:
	for item in moves_executed_box.get_children():
		item.queue_free()
	
	for move in level.executed_moves:
		moves_executed_box.add_child(_get_content_item(move))
	
	await get_tree().process_frame
	
	moves_executed_scroll.scroll_horizontal = int(moves_executed_scroll.get_h_scroll_bar().max_value)
	

func _refresh_ui_pending_moves() -> void:
	for item in moves_pending_box.get_children():
		item.queue_free()
	
	for move in level.pending_moves:
		moves_pending_box.add_child(_get_content_item(move))
	
	moves_pending_scroll.scroll_horizontal = int(moves_pending_scroll.get_h_scroll_bar().max_value)

func _get_content_item(move: Player.DIRECTION) -> TextureRect:
	var item := TextureRect.new()

	item.custom_minimum_size = Vector2(32, 32)
	item.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	item.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

	match move:
		Player.DIRECTION.UP:
			item.texture = move_icon_up_texture
		Player.DIRECTION.DOWN:
			item.texture = move_icon_down_texture
		Player.DIRECTION.LEFT:
			item.texture = move_icon_left_texture
		Player.DIRECTION.RIGHT:
			item.texture = move_icon_right_texture

	return item

func _update_buttons_state():
	if level.pending_moves.is_empty():
		bt_play.disabled = true
		
	if player.is_moving:
		bt_play.disabled = true
		bt_up.disabled = true
		bt_down.disabled = true
		bt_left.disabled = true
		bt_right.disabled = true
	else:
		bt_play.disabled = false
		bt_up.disabled = false
		bt_down.disabled = false
		bt_left.disabled = false
		bt_right.disabled = false

func _update_healt_ui():
	if player.is_alive:
		match player.healt:
			1: 
				heart_1.texture = heart_texture
				heart_2.texture = heart_void_texture
				heart_3.texture = heart_void_texture
			2:
				heart_1.texture = heart_texture
				heart_2.texture = heart_texture
				heart_3.texture = heart_void_texture
			3:
				heart_1.texture = heart_texture
				heart_2.texture = heart_texture
				heart_3.texture = heart_texture

func _update_score_ui():
	score_value.set_text(str(player.score))

func _update_win_screen_ui():
	var time = level.get_time()
	win_position.set_text(str(ScoreServer.get_score_position(player.score,time)))
	win_score.set_text(str(player.score))
	win_movements.set_text(str(level.executed_moves.size()))
	win_time.set_text(Utils.format_time(time))

func _update_time_ui():
	time_value.set_text(Utils.format_time(level.get_current_time()))

func _update_movements_ui():
	movements_value.text = str(player.movements_count) + "/" + str(level.max_movements)


func _on_up_pressed() -> void:
	if player.is_moving:
		return
	
	level.pending_moves.push_back(player.DIRECTION.UP)
	_refresh_ui_pending_moves()

func _on_down_pressed() -> void:
	if player.is_moving:
		return
	
	level.pending_moves.push_back(player.DIRECTION.DOWN)
	_refresh_ui_pending_moves()

func _on_right_pressed() -> void:
	level.pending_moves.push_back(player.DIRECTION.RIGHT)
	_refresh_ui_pending_moves()

func _on_left_pressed() -> void:
	if player.is_moving:
		return
		
	level.pending_moves.push_back(player.DIRECTION.LEFT)
	_refresh_ui_pending_moves()

func _on_play_pressed() -> void:
	if player.is_moving:
		return
	
	var executed_moves = await player.execute_pending_moves(level.pending_moves.duplicate())
	level.pending_moves.clear()
	
	level.executed_moves.append_array(executed_moves)
	
	_refresh_ui_move_lists()


func _on_exit_pressed() -> void:
	await fade_in()
	get_tree().change_scene_to_file("res://Gui/main_screen.tscn")

func _on_restart_pressed() -> void:
	await fade_in()
	level_maneger.reload_level()
	hub.show()
	game_over.hide()
	await fade_out()


func _on_cancel_pressed() -> void:
	await fade_in()
	hub.show()
	game_win.hide()
	level_maneger.reload_level()
	await fade_out()


func _on_accept_pressed() -> void:
	if win_input.text.strip_edges().is_empty():
		win_input_label.set_text("game.win.input.error")
		win_input.text = ""
		return
	else:
		win_input_label.text = ""

	var player_name = win_input.text.strip_edges()
	var time = (level.end_time - level.start_time) / 1000.0
	
	ScoreServer.save_score(player_name, player.score, level.executed_moves, time)
	
	await fade_in()
	win_input.text = ""
	hub.show()
	game_win.hide()
	
	level_maneger.reload_to_random_level()
	await fade_out()
