extends CharacterBody2D

@export var speed: float = 200.0
@export var jump_force: float = -400.0
@export var gravity: float = 900.0

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0 if velocity.y > 0 else velocity.y

	# Reset horizontal velocity
	velocity.x = 0

	# Movement input
	var direction = Vector2.ZERO
	if Input.is_action_pressed("ui_left"):
		velocity.x = -speed
		direction.x = -1
	elif Input.is_action_pressed("ui_right"):
		velocity.x = speed
		direction.x = 1

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_force

	move_and_slide()

	# Animate
	var sprite = $AnimatedSprite2D
	if direction.x != 0:
		sprite.play("walk")
		sprite.flip_h = direction.x < 0  # flip sprite when moving left
	else:
		sprite.play("idle")
