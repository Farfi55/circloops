extends Node

var levels: Dictionary = {}
@export var levels_folder: String = "res://scenes/levels"

func _ready() -> void:
	preload_levels()

func preload_levels():
	var dir = DirAccess.open(levels_folder)
	
	if dir == null:
		push_error("Failed to open levels folder: " + levels_folder)
		return

	var regex = RegEx.new()
	regex.compile("^level_(\\d+)$")  # Matches "level_k" and captures k

	dir.list_dir_begin()
	var file_name = dir.get_next()
	
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tscn"):
			var base_name = file_name.get_basename()  # e.g. "level_3"
			var result = regex.search(base_name)
			if result:
				
				#Using the k of levels_k as key for the dictionary
				var level_num = int(result.get_string(1))
				levels[level_num] = ResourceLoader.load(levels_folder + "/" + file_name)
				
		file_name = dir.get_next()
	dir.list_dir_end()
	
	GlobalVariables.total_levels = levels.keys().size()
	print("total levels: " + str(GlobalVariables.total_levels))
	print("Preloaded levels: ", levels.keys())

func get_level(level_number: int) -> Node3D:
	if levels.has(level_number):
		return levels[level_number].instantiate()
	else:
		push_warning("Level '%s' not found!" % level_number)
		return null
