extends Node

var levels: Array[Dictionary] = []

const LEVELS_PATH = "res://Game/Levels/"

func _ready() -> void:
	var files = _get_dir_files(LEVELS_PATH)
	
	for file_name in files:
		if file_name.get_extension().to_lower() == "tscn":
			var name = file_name.get_basename()
			var path = LEVELS_PATH+ file_name
			
			levels.append({"name":name,"path":path})

func _get_dir_files(path: String) -> Variant:
	var directory = DirAccess.open(path)
	if directory == null:
		return
	
	## Se obtine la lista de archivos del directorio
	var files = directory.get_files()
	
	## Ordena la list de archivos de mayor a menor
	files.sort()
	
	return files
