extends AudioStreamPlayer

const music := preload("res://assets/music/circus-music-loop-362929.mp3")
const INITIAL_VOLUME: float = 50.0

func _ready() -> void:
	GlobalSignals.music_volume_changed.connect(_on_music_volume_changed)
	set_volume(INITIAL_VOLUME)
	
	stream = music
	autoplay = true
	play()

func _on_finished() -> void:
	play()

func _on_music_volume_changed(volume: float) -> void:
	set_volume(volume)

func set_volume(volume: float) -> void:
	var linear = clamp(volume / 100.0, 0.0, 1.0)
	volume_db = linear_to_db(linear)
