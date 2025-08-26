# Player.gd — Unified for Level 1 & Level 2
extends CharacterBody2D

# --- Movement / Physics ---
@export var speed: float = 200.0
@export var jump_force: float = -400.0
@export var gravity: float = 900.0
@export var coyote_time: float = 0.10
@export var jump_buffer_time: float = 0.10

# --- Void Kill (fall below Y) ---
@export var enable_void_kill: bool = true
@export var void_kill_y: float = 120.0
@export var auto_adjust_void_kill: bool = true   # fixes "no movement" if start Y >= void_kill_y

# --- Animations ---
# Will try in order: "walk", then "walk forward"
@export var walk_animations: PackedStringArray = ["walk", "walk forward"]
@export var idle_animation: StringName = "idle"

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var game: Node = get_node_or_null("/root/Game")

var _coyote: float = 0.0
var _jump_buffer: float = 0.0
var dead: bool = false

func _enter_tree() -> void:
	# So enemies/hazards can find the player immediately
	add_to_group("player")

func _ready() -> void:
	# Auto-fix: if player starts at/under void_kill_y, push the threshold far below
	if auto_adjust_void_kill and enable_void_kill and global_position.y >= void_kill_y:
		void_kill_y = global_position.y + 1500.0
	# Debug (اختياري): اطبعي القيم لو بدك تتأكدي
	# print("start_y:", global_position.y, " void_kill_y:", void_kill_y)

func _physics_process(delta: float) -> void:
	if dead:
		return

	# Gravity + coyote window
	if is_on_floor():
		_coyote = coyote_time
		# clear residual downward velocity on landing
		if velocity.y > 0.0:
			velocity.y = 0.0
	else:
		_coyote = max(0.0, _coyote - delta)
		velocity.y += gravity * delta

	# Horizontal input
	var dir := 0.0
	if Input.is_action_pressed("ui_left"):
		dir -= 1.0
	if Input.is_action_pressed("ui_right"):
		dir += 1.0
	velocity.x = dir * speed

	# Jump buffer (press slightly before landing)
	if Input.is_action_just_pressed("ui_accept"):
		_jump_buffer = jump_buffer_time
	_jump_buffer = max(0.0, _jump_buffer - delta)

	if _jump_buffer > 0.0 and _coyote > 0.0:
		velocity.y = jump_force
		_jump_buffer = 0.0
		_coyote = 0.0

	move_and_slide()

	# Kill if we fall below threshold
	if enable_void_kill and global_position.y > void_kill_y:
		take_damage(999)

	# Animations
	_update_animation(dir)

# Enemies/hazards call this to kill/damage the player
func take_damage(amount: int = 1, knockback: Vector2 = Vector2.ZERO) -> void:
	if dead:
		return
	dead = true
	# Optional small knockback
	# if knockback != Vector2.ZERO:
	# 	velocity = knockback
	_die()

func _die() -> void:
	if game:
		game.call("on_player_death")
	else:
		get_tree().reload_current_scene()

func _update_animation(dir: float) -> void:
	if not sprite:
		return
	if abs(velocity.x) > 0.1:
		_play_first_available(walk_animations)
		sprite.flip_h = velocity.x < 0.0
	else:
		if sprite.sprite_frames and sprite.sprite_frames.has_animation(idle_animation):
			sprite.play(idle_animation)
		else:
			sprite.stop()

func _play_first_available(candidates: PackedStringArray) -> void:
	if not sprite or not sprite.sprite_frames:
		return
	for name in candidates:
		if sprite.sprite_frames.has_animation(name):
			sprite.play(name)
			return
	sprite.play()
	
func _on_burger_body_entered(body: Node2D) -> void:
	if body == self:
		if game and game.has_method("add_score"):
			game.call("add_score", 1)
		# اختياري: queue_free() للعنصر من سكربت العنصر نفسه

func _on_candy_body_entered(body: Node2D) -> void:
	if body == self:
		if game and game.has_method("add_score"):
			game.call("add_score", 1)

func _on_donat_body_entered(body: Node2D) -> void:
	if body == self:
		if game and game.has_method("add_score"):
			game.call("add_score", 1)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == self:
		take_damage(1)
