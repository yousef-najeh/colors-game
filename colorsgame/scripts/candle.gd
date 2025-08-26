# Wax.gd — kills player on touch
extends Area2D

@export var damage: int = 1
@export var knockback: Vector2 = Vector2.ZERO  # اختياري

func _ready() -> void:
	monitoring = true
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage") or body.is_in_group("player"):
		# اطرديه شوي لو بدك ارتداد
		body.call("take_damage", damage, knockback)
		# print("WAX HIT:", body.name)  # للتشخيص مؤقتًا
