extends GPUParticles3D

@export var delay := 0.0
func _init():
	GlobalSignals.level_won.connect(_on_level_won)
	
func _on_level_won():
	if delay > 0:
		await get_tree().create_timer(delay).timeout
	
	restart()
	$ConfettiSFX.play()
