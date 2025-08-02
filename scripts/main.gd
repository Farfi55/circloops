class_name Main
extends Control

@onready var level_loader: Node = $LevelLoader
@onready var level_container: Node3D = $Game/LevelContainer
@onready var ring_container: Node3D = $Game/RingContainer
@onready var ui: CanvasLayer = $UI
@onready var seconds_label: Label = $UI/GUI/MarginContainer/Seconds
@onready var level_timer: Timer = $Game/LevelTimer

const TIME_SCALE: float = 1.0
const TIME_SCALE_ZERO: float = 0.0
const LEVEL_TIME_LEFT: int = 60

var isInGame: bool = false
var isPaused: bool = false

func _ready() -> void:
	GlobalSignals.pause.connect(_on_pause)
	GlobalSignals.level_closed.connect(_on_level_closed)
	GlobalSignals.quit.connect(_on_quit)
	GlobalSignals.level_won.connect(_on_level_won)
	GlobalSignals.level_opened.connect(_on_level_opened)
	
	populate_savedata()
	
	# set first level unlocked
	GlobalVariables.savedata[1][0] = true
	
	GlobalVariables.current_level = level_loader.get_level(1)

	ui.show_menu()

func populate_savedata() -> void:
	for level in level_loader.levels.keys():
		# unlocked, time_elapsed, n_loops
		GlobalVariables.savedata[level] = [false, 0.0, 0]

func _on_level_opened() -> void:
	level_container.add_child(GlobalVariables.current_level)
	GlobalVariables.level_loaded_at_time = Time.get_ticks_msec() / 1000
	GlobalVariables.rings_thrown_level = 0
	ui.show_gui()
	print("current level:" + str(GlobalVariables.current_level_num))
	
	level_timer.start()
	
	print(GlobalVariables.savedata)
	
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
	pass

func _on_level_closed():
	for child in level_container.get_children(true):
		child.queue_free()
	
	for child in ring_container.get_children(true):
		child.queue_free()

func quit() -> void:
	get_tree().quit()

func _on_quit() -> void:
	# Save level state
	quit()
