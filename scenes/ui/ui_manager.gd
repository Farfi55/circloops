extends CanvasLayer

@onready var main_menu: Control = $MainMenu
@onready var loading: Control = $Loading
@onready var pause: Control = $Pause
@onready var gui: Control = $GUI
@onready var settings: Control = $Settings
@onready var bg: TextureRect = $Circus
@onready var winning: Control = $Winning
@onready var level_selector: Control = $LevelSelector
@onready var level_loader: Node = $"../LevelLoader"
@onready var item_list: ItemList = $LevelSelector/MarginContainer/VBoxContainer/ItemList
@onready var next_level: Button = $Winning/MarginContainer/VBoxContainer/NextLevel

@onready var music_slider: HSlider = $Settings/MarginContainer/VBoxContainer/VBoxContainer/MarginContainer2/VBoxContainer/MusicSlider
@onready var sfx_slider: HSlider = $Settings/MarginContainer/VBoxContainer/VBoxContainer/MarginContainer2/VBoxContainer/SFXSlider

var inGame: bool = false

func _ready() -> void:
	music_slider.value = GlobalVariables.INITIAL_VOLUME
	sfx_slider.value = GlobalVariables.INITIAL_VOLUME
	
	GlobalSignals.level_won.connect(_on_level_won)

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
	if item_list.item_count == 0:
		var keys = level_loader.levels.keys()
		
		keys.sort()
		
		for key in keys:
			var label: String = "Level " + str(key)
			item_list.add_item(label)
			
		item_list.item_selected.connect(_on_level_label_pressed)
	else:
		item_list.deselect_all()

func _on_level_label_pressed(level_key) -> void:
	GlobalVariables.current_level = level_loader.get_level(level_key + 1)
	GlobalVariables.current_level_num = level_key + 1
	print("Current level: " + str(level_key + 1))
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
	else:
		next_level.visible = false
