extends Area2D


func _on_body_entered(body: Node2D) -> void:
	AIManager.show_message("donat")
	queue_free()
