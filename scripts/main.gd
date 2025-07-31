extends Control

@onready var level_loader: Node = $LevelLoader
@onready var game: Node3D = $Game

func _ready() -> void:
	var level: Node3D = level_loader.get_level(1)
	print("Level loaded: " +  level.name)
	game.add_child(level)
