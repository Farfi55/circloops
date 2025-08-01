extends Node

@warning_ignore_start("unused_signal")

signal successful_throw(ring: Ring)
signal new_ring(ring: Ring)

# UI
signal new_game
signal pause(state: bool)
signal level_closed
signal game_over
