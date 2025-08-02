extends Button

@onready var audio_stream_player_2d: AudioStreamPlayer2D = $AudioStreamPlayer2D

const CLICK_1 = preload("res://assets/sfx/click1.ogg")
const MOUSECLICK_1 = preload("res://assets/sfx/mouseclick1.ogg")

func _ready() -> void:
	audio_stream_player_2d.stream = CLICK_1


func _on_pressed() -> void:
	audio_stream_player_2d.stream = CLICK_1
	audio_stream_player_2d.play()
	
func _on_mouse_entered() -> void:
	audio_stream_player_2d.stream = MOUSECLICK_1
	audio_stream_player_2d.play()
