extends CanvasLayer

@onready var main_menu: MarginContainer = $MainMenu
@onready var loading_screen: Control = $LoadingScreen
@onready var game_over: Control = $GameOver

func hide_all() -> void:
	main_menu.visible = false
	loading_screen.visible = false
	game_over.visible = false

func show_menu() -> void:
	hide_all()
	main_menu.visible = true

func show_gui() -> void:
	hide_all()
	# add gui when/if available

func show_loading() -> void:
	hide_all()
	loading_screen.visible = true

func show_game_over() -> void:
	hide_all()
	game_over.visible = true

func _on_play_pressed() -> void:
	GlobalSignals.new_game.emit()
