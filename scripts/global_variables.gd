extends Node

const INITIAL_VOLUME: float = 50.0

var current_level: Node3D
var total_levels: int
var current_level_num: int 

var rings_thrown_level := 0
var rings_thrown_total := 0
var level_loaded_at_time := 0.0

var savedata: Dictionary = {}

@onready var level_container: Node3D = $"../Main/Game/LevelContainer"
