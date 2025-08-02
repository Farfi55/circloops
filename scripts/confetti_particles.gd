extends GPUParticles3D

@export var delay := 0.0
@export var play_on_level_won := true

func _init():
	print("%s play_on_level_won %s" % [self.name, play_on_level_won])
	if play_on_level_won == true:
		GlobalSignals.level_won.connect(play)
	
func play():
	if delay > 0:
		await get_tree().create_timer(delay).timeout
	
	restart()
	$ConfettiSFX.play()
	
