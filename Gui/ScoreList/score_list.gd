extends ScrollContainer

@onready var list = $VBox

var list_item: PackedScene = preload("res://Gui/ScoreList/score_item.tscn")

func update():
	for n in list.get_children():
		n.free()
	
	var scores = ScoreServer.get_scores()
	var position := 0

	for score in scores:
		position+=1
		var instantiate = list_item.instantiate()
		
		list.add_child(instantiate)
		instantiate.set_values(position,score.time, score.score,score.movements.size(), score.name)
