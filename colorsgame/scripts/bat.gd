# Bat.gd — vertical patrol + horizontal sway + touch damage (Area2D)
extends Area2D

@export var speed: float = 55.0
@export var turn_pause: float = 0.12
@export var start_dir_down: bool = true

# Horizontal sway (0 = off)
@export var sway_amp: float = 8.0
@export var sway_freq_hz: float = 1.0

# Touch damage
@export var hurt_on_touch: bool = true
@export var damage: int = 1

# Vertical bounds: assign or auto ("TopBound"/"BottomBound" under parent)
@export var top_bound_node: Node2D
@export var bottom_bound_node: Node2D

# Path to sprite (optional anim)
@export var sprite_path: NodePath = "AnimatedSprite2D"

var dir := 1                     # 1 = down, -1 = up
var top_y: float
var bottom_y: float
var pause_t := 0.0
var use_bounds := false
var t := 0.0
var base_x: float

@onready var sprite: Node = null
@onready var parent2d: Node2D = null

func _ready() -> void:
	add_to_group("enemy")
	body_entered.connect(_on_body_entered)

	sprite = get_node_or_null(sprite_path)
	parent2d = get_parent() as Node2D

	# Auto-detect bounds
	if not top_bound_node and parent2d:
		top_bound_node = parent2d.get_node_or_null("TopBound") as Node2D
	if not bottom_bound_node and parent2d:
		bottom_bound_node = parent2d.get_node_or_null("BottomBound") as Node2D

	if top_bound_node and bottom_bound_node:
		top_y = min(top_bound_node.global_position.y, bottom_bound_node.global_position.y)
		bottom_y = max(top_bound_node.global_position.y, bottom_bound_node.global_position.y)
		use_bounds = true

	dir = 1 if start_dir_down else -1
	base_x = global_position.x

	# Optional animation
	if sprite is AnimatedSprite2D:
		var aspr := sprite as AnimatedSprite2D
		if aspr.sprite_frames and aspr.sprite_frames.has_animation("fly"):
			aspr.play("fly")
		else:
			aspr.play()

func _physics_process(delta: float) -> void:
	if pause_t > 0.0:
		pause_t -= delta
		return

	t += delta
	var gp := global_position
	gp.y += float(dir) * speed * delta

	# Sway on X
	if sway_amp != 0.0:
		gp.x = base_x + sin(TAU * sway_freq_hz * t) * sway_amp

	if use_bounds:
		if gp.y <= top_y:
			gp.y = top_y
			_turn()
		elif gp.y >= bottom_y:
			gp.y = bottom_y
			_turn()

	global_position = gp

func _turn() -> void:
	dir *= -1
	pause_t = turn_pause
	# Normally we don't flip vertically for bats; keep as-is.

func _on_body_entered(body: Node) -> void:
	if not hurt_on_touch:
		return
	if body.has_method("take_damage") or body.is_in_group("player"):
		body.call("take_damage", damage)
