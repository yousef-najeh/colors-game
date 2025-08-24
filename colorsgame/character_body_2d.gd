extends CharacterBody2D

@export var speed: float = 200.0
@export var jump_force: float = -400.0
@export var gravity: float = 900.0

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		# Stop tiny gravity accumulation when grounded
		velocity.y = 0 if velocity.y > 0 else velocity.y

	# Reset horizontal velocity
	velocity.x = 0

	# Move left
	if Input.is_action_pressed("ui_left"):
		velocity.x = -speed
	# Move right
	elif Input.is_action_pressed("ui_right"):
		velocity.x = speed

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_force

	move_and_slide()
