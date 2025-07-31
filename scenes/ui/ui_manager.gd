extends CanvasLayer

@onready var main_menu: MarginContainer = $MainMenu
@onready var loading_screen: Control = $LoadingScreen
@onready var game_over: Control = $GameOver


func show_menu() -> void:
	main_menu.visible = true
	loading_screen.visible = false
	game_over.visible = false

func show_gui() -> void:
	main_menu.visible = false
	loading_screen.visible = false
	game_over.visible = false
	# add gui when/if available

func show_loading() -> void:
	main_menu.visible = false
	loading_screen.visible = true
	game_over.visible = false

func show_game_over() -> void:
	main_menu.visible = false
	loading_screen.visible = false
	game_over.visible = true

func _on_play_pressed() -> void:
	GlobalSignals.new_game.emit()
