extends Control

@onready var level_loader: Node = $LevelLoader
@onready var level_container: Node3D = $Game/LevelContainer
@onready var ring_container: Node3D = $Game/RingContainer
@onready var ui: CanvasLayer = $UI

const TIME_SCALE: float = 1.0
const TIME_SCALE_ZERO: float = 0.0

var isInGame: bool = false
var isPaused: bool = false
var current_level: Node3D

func _ready() -> void:
	GlobalSignals.pause.connect(_on_pause)
	GlobalSignals.level_closed.connect(_on_level_closed)
	GlobalSignals.quit.connect(_on_quit)
	GlobalSignals.level_won.connect(_on_level_won)
	GlobalSignals.level_opened.connect(_on_level_opened)
	
	GlobalVariables.current_level = level_loader.get_level(1)
	
	ui.show_menu()

func _on_level_opened() -> void:
	level_container.add_child(GlobalVariables.current_level)
	ui.show_gui()
	
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
	for child in level_container.get_children(true):
		child.queue_free()
	
	for child in ring_container.get_children(true):
		child.queue_free()
	
	GlobalVariables.current_level.queue_free()

func quit() -> void:
	get_tree().quit()

func _on_quit() -> void:
	# Save level state
	quit()
