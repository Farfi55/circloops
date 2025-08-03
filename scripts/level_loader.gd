extends Node

class_name LevelLoader

const levels_path: Array[PackedScene] = [
	preload("res://scenes/levels/level_1.tscn"),
	preload("res://scenes/levels/level_2.tscn"),
	preload("res://scenes/levels/level_3.tscn"),
	preload("res://scenes/levels/level_4.tscn"),
	preload("res://scenes/levels/level_5.tscn"),
	preload("res://scenes/levels/level_6.tscn"),
	preload("res://scenes/levels/level_7.tscn"),
	preload("res://scenes/levels/level_8.tscn"),
	preload("res://scenes/levels/level_9.tscn"),
	preload("res://scenes/levels/level_10.tscn"),
	preload("res://scenes/levels/level_11.tscn"),
	preload("res://scenes/levels/level_12.tscn"),
	preload("res://scenes/levels/level_13.tscn"),
	preload("res://scenes/levels/level_14.tscn"),
	preload("res://scenes/levels/level_15.tscn"),
]

var levels: Dictionary;

var levels_count:
	get:
		return levels_path.size()

func _init() -> void:
	for i in range(levels_count):
		levels[i+1] = levels_path[i]
	GlobalVariables.total_levels = levels_count

func get_level(level_number: int) -> Node3D:
	if levels.has(level_number):
		return levels[level_number].instantiate()
	else:
		push_warning("Level %d not found!" % level_number)
		return null


#func preload_levels():
	#var dir = DirAccess.open(levels_folder)
	#
	#if dir == null:
		#push_error("Failed to open levels folder: " + levels_folder)
		#return
#
	#var regex = RegEx.new()
	#regex.compile("^level_(\\d+)$")  # Matches "level_k" and captures k
#
	#dir.list_dir_begin()
	#var file_name = dir.get_next()
	#
	#while file_name != "":
		#if not dir.current_is_dir() and file_name.ends_with(".tscn"):
			#var base_name = file_name.get_basename()  # e.g. "level_3"
			#var result = regex.search(base_name)
			#if result:
				#
				##Using the k of levels_k as key for the dictionary
				#var level_num = int(result.get_string(1))
				#levels[level_num] = ResourceLoader.load(levels_folder + "/" + file_name)
				#
		#file_name = dir.get_next()
	#dir.list_dir_end()
	#
	#GlobalVariables.total_levels = levels.keys().size()
	#print("total levels: " + str(GlobalVariables.total_levels))
	#print("Preloaded levels: ", levels.keys())
