extends AudioStreamPlayer

func _ready() -> void:
	GlobalSignals.sfx_volume_changed.connect(_on_sfx_volume_changed)
	volume_db = GlobalVariables.sfx_volume

func _on_sfx_volume_changed(volume: float) -> void:
	volume_db = volume
