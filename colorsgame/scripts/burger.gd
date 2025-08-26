extends Area2D

func _on_body_entered(body: Node2D) -> void:
	await AIManager.show_message("burger")  
	queue_free()
