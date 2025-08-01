extends Node

const INITIAL_VOLUME: float = 50.0

var music_volume: float
var sfx_volume: float

var current_level: Node3D
var total_levels: int
var current_level_num: int 

func _ready() -> void:
	GlobalSignals.music_volume_changed.connect(_on_music_volume_changed)
	GlobalSignals.sfx_volume_changed.connect(_on_sfx_volume_changed)

func _on_music_volume_changed(volume: float) -> void:
	music_volume = volume
	
func _on_sfx_volume_changed(volume: float) -> void:
	sfx_volume = volume
