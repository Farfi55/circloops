extends AudioStreamPlayer

const music := preload("res://assets/music/circus-music-loop-362929.mp3")

func _ready() -> void:
	GlobalSignals.music_volume_changed.connect(_on_music_volume_changed)
	
	stream = music
	autoplay = true
	play()

func _on_music_volume_changed(volume: float):
	volume_db = volume

func _on_finished() -> void:
	play()
