extends CanvasLayer

@onready var main_menu: Control = $MainMenu
@onready var loading: Control = $Loading
@onready var pause: Control = $Pause
@onready var gui: Control = $GUI

func hide_all() -> void:
	main_menu.visible = false
	loading.visible = false
	pause.visible = false
	GlobalSignals.pause.emit(pause.visible)

func show_menu() -> void:
	hide_all()
	main_menu.visible = true

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

func _on_play_pressed() -> void:
	GlobalSignals.new_game.emit()

func _on_continue_pressed() -> void:
	show_gui()

func _on_main_menu_pressed() -> void:
	hide_all()
	GlobalSignals.level_closed.emit()
	main_menu.visible = true

func _on_quit_pressed() -> void:
	GlobalSignals.quit.emit()
