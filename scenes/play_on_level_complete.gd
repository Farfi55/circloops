extends AudioStreamPlayer

func _init() -> void:
	GlobalSignals.level_won.connect(play)
	GlobalSignals.level_closed.connect(stop)
