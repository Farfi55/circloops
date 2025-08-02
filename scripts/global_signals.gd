extends Node

@warning_ignore_start("unused_signal")

signal successful_throw(ring: Ring)
signal new_ring(ring: Ring)
signal ring_thrown(ring: Ring)

# UI
signal pause(state: bool)
signal level_opened
signal level_closed
signal level_won
signal game_over
signal quit
