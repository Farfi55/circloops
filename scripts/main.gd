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
var canPause: bool = false

var _targets_in_level: int = 1
var _remaining_targets: int = _targets_in_level

@export var unlock_all_levels = false

func _ready() -> void:
	GlobalSignals.pause.connect(_on_pause)
	GlobalSignals.level_closed.connect(_on_level_closed)
	GlobalSignals.quit.connect(_on_quit)
	GlobalSignals.level_won.connect(_on_level_won)
	GlobalSignals.level_opened.connect(_on_level_opened)
	
	populate_savedata()
	
	# set first level unlocked
	GlobalVariables.savedata[1][0] = true
	
	GlobalSignals.successful_throw.connect(_successful_throw)

	GlobalVariables.current_level = level_loader.get_level(1)

	ui.show_menu()

func populate_savedata() -> void:
	for level in level_loader.levels.keys():
		# unlocked, time_elapsed, n_loops
		GlobalVariables.savedata[level] = [unlock_all_levels, INF, 99999999]

func _on_level_opened() -> void:
	level_container.add_child(GlobalVariables.current_level)
	GlobalVariables.level_loaded_at_time = Time.get_ticks_msec() / 1000
	GlobalVariables.rings_thrown_level = 0
	
	_targets_in_level = get_tree().get_nodes_in_group("sticks").size()
	_remaining_targets = _targets_in_level
	
	ui.show_gui()
	print("current level:" + str(GlobalVariables.current_level_num))
	print("_remaining_targets: %d" % _remaining_targets)
	
	level_timer.start()
	
	print(GlobalVariables.savedata)
	
	isInGame = true
	isPaused = false
	canPause = true
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_esc"):
		if not isInGame:
			quit()
		elif not isPaused:
			if canPause:
				isPaused = true
				ui.show_pause()
		else:
			isPaused = false
			ui.show_gui()
			

func _on_pause(state:bool) -> void:
	if state == true:
		Engine.time_scale = TIME_SCALE_ZERO
	else:
		Engine.time_scale = TIME_SCALE

func _on_level_won() -> void:
	canPause = false

func _on_level_closed():
	isInGame = false
	isPaused = false
	for child in level_container.get_children(true):
		child.queue_free()
		level_container.remove_child(child)
		
	
	for child in ring_container.get_children(true):
		child.queue_free()

func _successful_throw(_ring: Ring):
	_remaining_targets -= 1
	if _remaining_targets == 0:
		GlobalSignals.level_won.emit()

func quit() -> void:
	get_tree().quit()

func _on_quit() -> void:
	# Save level state
	quit()
