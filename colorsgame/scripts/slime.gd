# Slime.gd — horizontal patrol + touch damage with optional "top-only" condition (Area2D)
extends Area2D

@export var speed: float = 40.0
@export var damage: int = 1
@export var hurt_only_when_player_lands_on_top: bool = false  # set true for "Mario-style" top-only
@export var turn_pause: float = 0.12

# Patrol bounds (assign nodes or auto)
@export var left_bound_node: Node2D
@export var right_bound_node: Node2D

# Path to sprite for flip support
@export var sprite_path: NodePath = "AnimatedSprite2D"

var dir: int = -1
var left_x: float
var right_x: float
var pause_t := 0.0
var use_bounds := false

@onready var sprite_node: Node = null
@onready var parent2d: Node2D = null

func _ready() -> void:
	add_to_group("enemy")
	body_entered.connect(_on_body_entered)

	sprite_node = get_node_or_null(sprite_path)
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

	# Optional animation
	if sprite_node is AnimatedSprite2D:
		var aspr := sprite_node as AnimatedSprite2D
		if aspr.sprite_frames and aspr.sprite_frames.has_animation("walk"):
			aspr.play("walk")
		else:
			aspr.play()

	_apply_flip() # initial flip

func _physics_process(delta: float) -> void:
	if pause_t > 0.0:
		pause_t -= delta
		return

	position.x += float(dir) * speed * delta

	if use_bounds:
		if position.x <= left_x:
			position.x = left_x
			_turn()
		elif position.x >= right_x:
			position.x = right_x
			_turn()

func _turn() -> void:
	dir *= -1
	pause_t = turn_pause
	_apply_flip()

func _apply_flip() -> void:
	# Flip horizontally based on moving direction; assume sprite faces right by default.
	if sprite_node is AnimatedSprite2D:
		(sprite_node as AnimatedSprite2D).flip_h = (dir < 0)
	elif sprite_node is Sprite2D:
		(sprite_node as Sprite2D).flip_h = (dir < 0)

func _on_body_entered(body: Node) -> void:
	if not (body.has_method("take_damage") or body.is_in_group("player")):
		return

	if not hurt_only_when_player_lands_on_top:
		body.call("take_damage", damage)
		return

	# Top-only damage: require player to be above slime and falling
	var player_above := false
	if body is Node2D:
		player_above = (body as Node2D).global_position.y < self.global_position.y - 4.0

	var falling := true
	if body is CharacterBody2D:
		falling = (body as CharacterBody2D).velocity.y > 0.0

	if player_above and falling:
		body.call("take_damage", damage)
