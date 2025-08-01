extends AudioStreamPlayer

func _init() -> void:
	GlobalSignals.level_won.connect(_play)
	GlobalSignals.level_closed.connect(_stop)
	
func _play() -> void: 
	play()

func _stop() -> void:
	stop()
