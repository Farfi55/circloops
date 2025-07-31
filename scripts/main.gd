extends Control

@onready var level_loader: Node = $LevelLoader
@onready var game: Node3D = $Game
@onready var ui: CanvasLayer = $UI

func _ready() -> void:
	GlobalSignals.new_game.connect(_on_new_game)
	ui.show_menu()
	
	#var level: Node3D = level_loader.get_level(1)
	#print("Level loaded: " +  level.name)
	#game.add_child(level)

func _on_new_game() -> void:
	ui.show_gui()
	game.add_child(level_loader.get_level(1))
