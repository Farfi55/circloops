extends CanvasLayer

@onready var main_menu: Control = $MainMenu
@onready var loading: Control = $Loading
@onready var pause: Control = $Pause
@onready var gui: Control = $GUI
@onready var settings: Control = $Settings
@onready var bg: TextureRect = $Circus

func hide_all() -> void:
	main_menu.visible = false
	loading.visible = false
	pause.visible = false
	gui.visible = false
	settings.visible = false
	bg.visible = false
	GlobalSignals.pause.emit(pause.visible)

func show_menu() -> void:
	hide_all()
	main_menu.visible = true
	bg.visible = true

func show_gui() -> void:
	hide_all()
	gui.visible = true

func show_pause() -> void:
	hide_all()
	pause.visible = true
	GlobalSignals.pause.emit(pause.visible)

func show_loading() -> void:
	hide_all()
	loading.visible = true

func show_game_over() -> void:
	hide_all()
	#game_over.visible = true

func show_settings() -> void:
	hide_all()
	settings.visible = true
	bg.visible = true

func _on_play_pressed() -> void:
	GlobalSignals.new_game.emit()

func _on_continue_pressed() -> void:
	show_gui()

func _on_main_menu_pressed() -> void:
	show_menu()
	GlobalSignals.level_closed.emit()

func _on_quit_pressed() -> void:
	GlobalSignals.quit.emit()

func _on_settings_pressed() -> void:
	show_settings()

func _on_back_pressed() -> void:
	show_menu()

func _on_music_slider_value_changed(value: float) -> void:
	GlobalSignals.music_volume_changed.emit(value)
