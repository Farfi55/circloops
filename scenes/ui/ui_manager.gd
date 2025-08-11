extends CanvasLayer

@onready var main_menu: Control = $MainMenu
@onready var loading: Control = $Loading
@onready var pause: Control = $Pause
@onready var gui: Control = $GUI
@onready var settings: Control = $Settings
@onready var bg: TextureRect = $Circus
@onready var winning: Control = $Winning
@onready var label_level_won: Label = $Winning/MarginContainer/VBoxContainer/LabelLevelWon
@onready var label_time: Label = $Winning/MarginContainer/VBoxContainer/LabelTime
@onready var label_loops: Label = $Winning/MarginContainer/VBoxContainer/LabelLoops
@onready var label_game_completed: Label = $Winning/MarginContainer/VBoxContainer/LabelGameCompleted
@onready var label_current_level: Label = $GUI/MarginContainer/HBoxContainer/Level
@onready var label_current_seconds: Label = $GUI/MarginContainer/HBoxContainer/Seconds
@onready var pause_button: TextureButton = $GUI/MarginContainer/HBoxContainer/PauseButton


@onready var level_selector: Control = $LevelSelector
@onready var level_loader: Node = $"../LevelLoader"
@onready var grid_container: GridContainer = $LevelSelector/MarginContainer/VBoxContainer/GridContainer
@onready var levels_completed_label: Label = $LevelSelector/MarginContainer2/VBoxContainer/LevelsCompletedLabel
@onready var loops_thrown_label: Label = $LevelSelector/MarginContainer2/VBoxContainer/LoopsThrownLabel
@onready var time_taken_label: Label = $LevelSelector/MarginContainer2/VBoxContainer/TimeTakenLabel

@onready var next_level: Button = $Winning/MarginContainer/VBoxContainer/NextLevel

@onready var music_slider: HSlider = $Settings/MarginContainer/VBoxContainer/VBoxContainer/MarginContainer2/VBoxContainer/MusicSlider
@onready var sfx_slider: HSlider = $Settings/MarginContainer/VBoxContainer/VBoxContainer/MarginContainer2/VBoxContainer/SFXSlider


var lock_icon: Texture2D = preload("res://assets/icons/lock.tres")

var inGame: bool = false
var time_diff: int

var music_bus := AudioServer.get_bus_index("Music")
var sfx_bus := AudioServer.get_bus_index("SFX")

func _ready() -> void:
	music_slider.value = AudioServer.get_bus_volume_linear(music_bus)
	sfx_slider.value = AudioServer.get_bus_volume_linear(sfx_bus)
	GlobalSignals.level_won.connect(_on_level_won)
	

func _process(delta: float) -> void:
	if inGame:
		time_diff = (Time.get_ticks_msec() / 1000) - GlobalVariables.level_loaded_at_time
		label_current_seconds.text = "%02d:%02d" % get_time_m_s(time_diff)

func get_time_m_s(time: float) -> Array[int]:
	var t = int(time)
	var mins: int = t / 60
	var sec: int = t % 60

	return [mins, sec]

func hide_all() -> void:
	main_menu.visible = false
	loading.visible = false
	pause.visible = false
	gui.visible = false
	settings.visible = false
	winning.visible = false
	level_selector.visible = false
	bg.visible = false
	
	GlobalSignals.pause.emit(pause.visible)

func show_menu() -> void:
	hide_all()
	main_menu.visible = true
	bg.visible = true

func show_gui() -> void:
	hide_all()
	gui.visible = true
	inGame = true

func show_pause() -> void:
	hide_all()
	pause.visible = true
	GlobalSignals.pause.emit(pause.visible)

func show_loading() -> void:
	hide_all()
	loading.visible = true
	bg.visible = true

func show_game_over() -> void:
	hide_all()
	#game_over.visible = true

func show_winning() -> void:
	hide_all()
	winning.visible = true

func show_settings() -> void:
	hide_all()
	settings.visible = true
	bg.visible = true

func show_level_selector() -> void:
	hide_all()
	show_levels()
	level_selector.visible = true
	bg.visible = true


func show_levels() -> void:
	for child in grid_container.get_children():
		child.queue_free()

	var keys = level_loader.levels.keys()
	keys.sort()

	
	grid_container.columns = 2
	var rows := ceili(GlobalVariables.total_levels / 2)

	var reordered_keys: Array = []
	for row in range(rows):
		for col in range(grid_container.columns):
			var idx := col * rows + row
			if idx < keys.size():
				reordered_keys.append(keys[idx])

	var levels_completed = 0
	var total_loops = 0
	var total_time = 0.0

	for key in reordered_keys:
		var saved = GlobalVariables.savedata.get(key, [])
		var unlocked = saved.size() > 0 and saved[0] == true
		var label_text := "Level %s" % key

		if unlocked:
			if saved[1] == INF:
				label_text += " — Uncompleted"
			else:
				levels_completed += 1
				total_loops += saved[2]
				total_time += saved[1]
				var t = get_time_m_s(saved[1])
				var time_str = "%02d:%02d" % [t[0], t[1]]
				label_text += " — Time: %s — Loops: %s" % [time_str, saved[2]]
		else:
			label_text += " — Locked"

		var btn = Button.new()
		btn.text = label_text
		btn.icon = null if unlocked else lock_icon
		btn.disabled = not unlocked
		btn.expand_icon = false
		btn.add_theme_constant_override("icon_max_width", 30)
		btn.custom_minimum_size = Vector2(480, 60)
		

		btn.pressed.connect(func():
			_on_level_selected(key)
		)

		grid_container.add_child(btn)

	# Stats
	levels_completed_label.text = "Levels Completed: %d/%d" % [levels_completed, GlobalVariables.total_levels]
	loops_thrown_label.text = "Loops Thrown: %d" % total_loops
	var time_str = "%02d:%02d" % get_time_m_s(total_time)
	time_taken_label.text = "Time Taken: %s" % time_str


func _on_level_selected(level_key: int) -> void:
	GlobalVariables.current_level = level_loader.get_level(level_key)
	GlobalVariables.current_level_num = level_key
	
	label_current_level.text = "Level: %s" % GlobalVariables.current_level_num
	GlobalSignals.level_opened.emit()

func _on_play_pressed() -> void:
	show_level_selector()
	#GlobalSignals.new_game.emit()

func _on_continue_pressed() -> void:
	GlobalSignals.pause_button_pressed.emit()

func _on_main_menu_pressed() -> void:
	show_menu()
	inGame = false
	GlobalSignals.level_closed.emit()
	if GlobalVariables.current_level != null:
		GlobalVariables.current_level.queue_free()

func _on_quit_pressed() -> void:
	GlobalSignals.quit.emit()

func _on_settings_pressed() -> void:
	show_settings()

func _on_back_pressed() -> void:
	if inGame:
		show_pause()
	else:
		show_menu()
		
func _on_level_won() -> void:
	time_diff = (Time.get_ticks_msec() / 1000) - GlobalVariables.level_loaded_at_time
	
	label_level_won.text = "Level %d Completed!" % GlobalVariables.current_level_num
	label_time.text = "You took: %02d:%02d" % get_time_m_s(time_diff)
	label_loops.text = "On this level you shot: %d loops, %d in total" % [GlobalVariables.rings_thrown_level, GlobalVariables.rings_thrown_total]
	
	var completed_final_level = GlobalVariables.current_level_num == GlobalVariables.total_levels
	
	label_game_completed.visible = completed_final_level
	next_level.visible = not completed_final_level
	
	var current_stats = GlobalVariables.savedata[GlobalVariables.current_level_num]
	var best_time = min(current_stats[1], time_diff)
	var best_rings = min(current_stats[2], GlobalVariables.rings_thrown_level)

	GlobalVariables.savedata[GlobalVariables.current_level_num] = [true, best_time, best_rings]
	
	show_winning()

func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(music_bus, value)

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(sfx_bus, value)


func _on_next_level_pressed() -> void:
	if GlobalVariables.current_level_num < GlobalVariables.total_levels:
		show_gui()
		
		GlobalVariables.current_level = level_loader.get_level(GlobalVariables.current_level_num + 1)
		GlobalVariables.current_level_num = GlobalVariables.current_level_num + 1
		
		GlobalSignals.level_closed.emit()
		GlobalSignals.level_opened.emit()
		
		label_current_level.text = "Level: " + str(GlobalVariables.current_level_num)

func _on_replay_level_pressed() -> void:
	if GlobalVariables.current_level != null:
		GlobalSignals.level_closed.emit()
		GlobalVariables.current_level.queue_free()
	
	show_gui()
	GlobalVariables.current_level = level_loader.get_level(GlobalVariables.current_level_num)
	GlobalSignals.level_opened.emit()
	
	label_current_level.text = "Level: " + str(GlobalVariables.current_level_num)


func _on_pause_button_pressed() -> void:
	GlobalSignals.pause_button_pressed.emit()
