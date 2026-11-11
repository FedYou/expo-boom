extends Node

var levels: Array[Dictionary] = [
	{
		"name": "Nivel 0",
		"path": "res://Game/Levels/level_0.tscn"
	},
	{
		"name": "Nivel 1",
		"path": "res://Game/Levels/level_1.tscn"
	},
	{
		"name": "Nivel 2",
		"path": "res://Game/Levels/level_2.tscn"
	}
]


func _get_dir_files(path: String) -> Variant:
	var directory = DirAccess.open(path)
	if directory == null:
		return
	
	## Se obtine la lista de archivos del directorio
	var files = directory.get_files()
	
	## Ordena la list de archivos de mayor a menor
	files.sort()
	
	return files
