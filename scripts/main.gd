extends Control

@onready var level_loader: Node = $LevelLoader
@onready var level_container: Node3D = $Game/LevelContainer
@onready var ui: CanvasLayer = $UI

const TIME_SCALE: float = 1.0
const TIME_SCALE_ZERO: float = 0.0

var isInGame: bool = false
var isPaused: bool = false
var current_level: Node3D

func _ready() -> void:
	GlobalSignals.new_game.connect(_on_new_game)
	GlobalSignals.pause.connect(_on_pause)
	GlobalSignals.level_closed.connect(_on_level_closed)
	GlobalSignals.quit.connect(_on_quit)
	GlobalSignals.level_won.connect(_on_level_won)
	
	ui.show_menu()
	
	#var level: Node3D = level_loader.get_level(1)
	#print("Level loaded: " +  level.name)
	#level_container.add_child(level)

func _on_new_game() -> void:
	
	ui.show_gui()
	
	current_level = level_loader.get_level(1)
	level_container.add_child(current_level)
	isInGame = true
	isPaused = false
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_esc"):
		if isInGame and isPaused == false:
			isPaused = true
			ui.show_pause()
		elif isInGame and isPaused == true:
			isPaused = false
			ui.show_gui()
		else:
			quit()
			


func _on_pause(state:bool) -> void:
	if state == true:
		Engine.time_scale = TIME_SCALE_ZERO
	else:
		Engine.time_scale = TIME_SCALE

func _on_level_won() -> void:
	#Engine.time_scale = TIME_SCALE_ZERO
	pass

func _on_level_closed():
	level_container.remove_child(current_level)
	current_level = null

func quit() -> void:
	get_tree().quit()

func _on_quit() -> void:
	# Save level state
	quit()
