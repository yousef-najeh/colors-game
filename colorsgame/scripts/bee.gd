# Bee.gd — horizontal patrol + hover + touch damage (Area2D)
extends Area2D

@export var speed: float = 60.0
@export var turn_pause: float = 0.12
@export var start_dir_right: bool = false

# Hover (0 = off)
@export var hover_amp: float = 8.0
@export var hover_freq_hz: float = 1.2

# Touch damage
@export var hurt_on_touch: bool = true
@export var damage: int = 1

# Patrol bounds: assign or auto-detect from parent children "LeftBound"/"RightBound"
@export var left_bound_node: Node2D
@export var right_bound_node: Node2D

# Path to sprite for flip support
@export var sprite_path: NodePath = "AnimatedSprite2D"

var dir: int = -1
var left_x: float
var right_x: float
var pause_t := 0.0
var use_bounds := false
var t := 0.0
var base_y: float

@onready var sprite: Node = null
@onready var parent2d: Node2D = null

func _ready() -> void:
	add_to_group("enemy")
	body_entered.connect(_on_body_entered)

	sprite = get_node_or_null(sprite_path)
	parent2d = get_parent() as Node2D

	# Auto-detect patrol bounds if not assigned
	if not left_bound_node and parent2d:
		left_bound_node = parent2d.get_node_or_null("LeftBound") as Node2D
	if not right_bound_node and parent2d:
		right_bound_node = parent2d.get_node_or_null("RightBound") as Node2D

	if left_bound_node and right_bound_node:
		left_x = min(left_bound_node.global_position.x, right_bound_node.global_position.x)
		right_x = max(left_bound_node.global_position.x, right_bound_node.global_position.x)
		use_bounds = true

	dir = 1 if start_dir_right else -1
	base_y = global_position.y

	# Optional animation
	if sprite is AnimatedSprite2D:
		var aspr := sprite as AnimatedSprite2D
		if aspr.sprite_frames and aspr.sprite_frames.has_animation("fly"):
			aspr.play("fly")
		else:
			aspr.play()

	_apply_flip() # initial flip

func _physics_process(delta: float) -> void:
	if pause_t > 0.0:
		pause_t -= delta
		return

	t += delta

	var gp := global_position
	gp.x += float(dir) * speed * delta

	# Hover
	if hover_amp != 0.0:
		gp.y = base_y + sin(TAU * hover_freq_hz * t) * hover_amp

	if use_bounds:
		if gp.x <= left_x:
			gp.x = left_x
			_turn()
		elif gp.x >= right_x:
			gp.x = right_x
			_turn()

	global_position = gp

func _turn() -> void:
	dir *= -1
	pause_t = turn_pause
	_apply_flip()

func _apply_flip() -> void:
	# Flip horizontally based on moving direction; assume sprite faces right by default.
	if sprite is AnimatedSprite2D:
		(sprite as AnimatedSprite2D).flip_h = (dir < 0)
	elif sprite is Sprite2D:
		(sprite as Sprite2D).flip_h = (dir < 0)

func _on_body_entered(body: Node) -> void:
	if not hurt_on_touch:
		return
	# Be tolerant: group OR method
	if body.has_method("take_damage") or body.is_in_group("player"):
		body.call("take_damage", damage)
