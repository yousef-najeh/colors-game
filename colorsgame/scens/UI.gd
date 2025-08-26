extends CanvasLayer

@export var message_label: Label  

func _ready() -> void:
	if message_label:
		AIManager.register_label(message_label)
	else:
		print("Warning: message_label not assigned!")
