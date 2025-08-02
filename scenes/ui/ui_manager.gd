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
@onready var label_current_level: Label = $GUI/MarginContainer/Level
@onready var label_current_seconds: Label = $GUI/MarginContainer/Seconds

@onready var level_selector: Control = $LevelSelector
@onready var level_loader: Node = $"../LevelLoader"
@onready var item_list: ItemList = $LevelSelector/MarginContainer/VBoxContainer/ItemList
@onready var next_level: Button = $Winning/MarginContainer/VBoxContainer/NextLevel

@onready var music_slider: HSlider = $Settings/MarginContainer/VBoxContainer/VBoxContainer/MarginContainer2/VBoxContainer/MusicSlider
@onready var sfx_slider: HSlider = $Settings/MarginContainer/VBoxContainer/VBoxContainer/MarginContainer2/VBoxContainer/SFXSlider

var lock_icon: Texture2D = preload("res://assets/icons/lock.tres")

var inGame: bool = false
var time_diff: int

func _ready() -> void:
	music_slider.value = GlobalVariables.INITIAL_VOLUME
	sfx_slider.value = GlobalVariables.INITIAL_VOLUME
	
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
	item_list.clear()
	item_list.icon_mode = ItemList.ICON_MODE_LEFT
	item_list.fixed_icon_size = Vector2i(24, 24)
	item_list.icon_scale = 1.0

	var keys = level_loader.levels.keys()
	keys.sort()

	for key in keys:
		var saved = GlobalVariables.savedata.get(key, [])
		var unlocked = saved[0] == true
		var label_text := "Level %s" % key

		if unlocked:
			var t = get_time_m_s(saved[1])
			var time_str = "%02d:%02d" % [t[0], t[1]]  # zero-padded minutes:seconds
			label_text += " — Time: %s, Loops: %s" % [time_str, saved[2]]
		else:
			label_text += " — Locked"

		var icon_used
		
		if unlocked:
			icon_used = null
		else:
			icon_used = lock_icon
		
		var idx = item_list.add_item(label_text, icon_used)
		item_list.set_item_disabled(idx, not unlocked)
		item_list.set_item_metadata(idx, key)
	
	if item_list.is_connected("item_selected", _on_level_selected):
		item_list.item_selected.connect(_on_level_selected)

func _on_level_selected(selected_idx: int) -> void:
	var level_key = item_list.get_item_metadata(selected_idx)
	GlobalVariables.current_level = level_loader.get_level(level_key)
	GlobalVariables.current_level_num = level_key
	
	label_current_level.text = "Level: %s" % GlobalVariables.current_level_num
	GlobalSignals.level_opened.emit()

func _on_play_pressed() -> void:
	show_level_selector()
	#GlobalSignals.new_game.emit()

func _on_continue_pressed() -> void:
	show_gui()

func _on_main_menu_pressed() -> void:
	show_menu()
	inGame = false
	GlobalSignals.level_closed.emit()
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
	label_loops.text = "On this level you shoot: %d loops, %d in total" % [GlobalVariables.rings_thrown_level, GlobalVariables.rings_thrown_total]
	
	var completed_final_level = GlobalVariables.current_level_num == GlobalVariables.total_levels
	
	label_game_completed.visible = completed_final_level
	next_level.visible = not completed_final_level
	
	GlobalVariables.savedata[GlobalVariables.current_level_num] = [true, time_diff, GlobalVariables.rings_thrown_level]
	
	if not completed_final_level:
		GlobalVariables.savedata[GlobalVariables.current_level_num + 1][0] = true
	
	show_winning()

func _on_music_slider_value_changed(value: float) -> void:
	GlobalSignals.music_volume_changed.emit(get_clamped_volume_db(value))

func _on_sfx_slider_value_changed(value: float) -> void:
	GlobalSignals.sfx_volume_changed.emit(get_clamped_volume_db(value))

func get_clamped_volume_db(volume_percent: float) -> float:
	var norm = clamp(volume_percent / 100.0, 0.0, 1.0)
	return linear_to_db(norm)

func _on_next_level_pressed() -> void:
	if GlobalVariables.current_level_num < GlobalVariables.total_levels:
		show_gui()
		
		GlobalVariables.current_level = level_loader.get_level(GlobalVariables.current_level_num + 1)
		GlobalVariables.current_level_num = GlobalVariables.current_level_num + 1
		
		GlobalSignals.level_closed.emit()
		GlobalSignals.level_opened.emit()
		
		label_current_level.text = "Level: " + str(GlobalVariables.current_level_num)
	else:
		next_level.visible = false
