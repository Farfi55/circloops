extends TextureButton

@export var url: String;

func _ready() -> void:
	pressed.connect(open_site)
		
func open_site():
	OS.shell_open(url)
