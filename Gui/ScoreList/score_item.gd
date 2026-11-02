extends GridContainer

@onready var _position = $PositionValue
@onready var time = $TimeValue
@onready var score = $ScoreValue
@onready var movements = $MovementsValue
@onready var _name = $NameValue

func set_values(p:int,t:float,s:int,m:int, n):
	_position.set_text(str(p))
	time.set_text(Utils.format_time(t))
	score.set_text(str(s))
	movements.set_text(str(m))
	_name.set_text(n) 
