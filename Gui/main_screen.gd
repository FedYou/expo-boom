extends Screen

@onready var camara = $Camera
@onready var main = $Gui/Main
@onready var score = $Gui/Score
@onready var language = $Gui/MarginLanguages/Language

@onready var score_list = $Gui/Score/List
@onready var language_option: OptionButton = $Gui/MarginLanguages/Language/LanguageOption



var main_position_camara: Vector2
var main_zoom_camara: Vector2 = Vector2(1,1)

@export_group("Camara")
@export var camara_duration: float

@export_group("Camara Score")
@export var score_position_camara: Vector2
@export var score_zoom_camara: Vector2

func _ready() -> void:
	camara.reset_smoothing()
	main_position_camara = Vector2(camara.limit_right/2, camara.limit_bottom/2)
	await fade_out()
	load_languages()


func load_languages() -> void:
	language_option.clear()

	var languages := TranslationServer.get_loaded_locales()

	var current_locale := TranslationServer.get_locale()
	print(current_locale)

	for i in languages.size():
		var locale := languages[i]
		
		if locale == "en":
			language_option.add_item("English")
		elif locale == "es":
			language_option.add_item("Español")
		elif locale == "it":
			language_option.add_item("Italiano")
		elif locale == "pt":
			language_option.add_item("Português")
		else:
			language_option.add_item(locale)
	
		if current_locale.begins_with(locale):
			language_option.select(i)


func _on_language_option_item_selected(index: int) -> void:
	var languages := TranslationServer.get_loaded_locales()

	TranslationServer.set_locale(languages[index])
	get_tree().reload_current_scene()


func _on_play_pressed() -> void:
	await fade_in()
	get_tree().change_scene_to_file("res://Game/game.tscn")

func _on_score_pressed() -> void:
	Utils.fade_out(main,0.5)
	score_list.update()
	await Utils.move_camara_2d(camara,score_position_camara,score_zoom_camara,camara_duration)
	Utils.fade_in(score,0.5)

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_back_pressed() -> void:
	Utils.fade_out(score,0.5)
	await Utils.move_camara_2d(camara,main_position_camara,main_zoom_camara,camara_duration)
	Utils.fade_in(main,0.5)
