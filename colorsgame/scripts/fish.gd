# Fish.gd — jump out of water and kill player on touch
extends Area2D

@export var fall_gravity: float = 1200.0      # كان اسمها gravity — غيّناه
@export var jump_speed: float = 520.0
@export var drift_speed: float = 0.0          # 0 = بدون انزياح أفقي
@export var jump_interval: float = 1.8
@export var interval_jitter: float = 0.6
@export var kill_damage: int = 1

var vel: Vector2 = Vector2.ZERO
var base_pos: Vector2
var wait_t: float = 0.0
var waiting: bool = true
var dir: int = 1

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	add_to_group("enemy")
	monitoring = true
	body_entered.connect(_on_body_entered)

	base_pos = global_position
	wait_t = _next_wait()
	randomize()

	if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation("idle"):
		sprite.play("idle")

func _physics_process(delta: float) -> void:
	if waiting:
		wait_t -= delta
		if wait_t <= 0.0:
			waiting = false
			vel = Vector2(0, -jump_speed)
			dir = (1 if randf() < 0.5 else -1)
			vel.x = drift_speed * dir
			if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation("jump"):
				sprite.play("jump")
	else:
		vel.y += fall_gravity * delta
		global_position += vel * delta

		if sprite:
			sprite.flip_h = vel.x < 0.0

		if global_position.y >= base_pos.y:
			global_position = base_pos
			vel = Vector2.ZERO
			waiting = true
			wait_t = _next_wait()
			if sprite and sprite.sprite_frames and sprite.sprite_frames.has_animation("idle"):
				sprite.play("idle")
			elif sprite:
				sprite.stop()

func _on_body_entered(body: Node) -> void:
	if body.has_method("take_damage") or body.is_in_group("player"):
		body.call("take_damage", kill_damage)

func _next_wait() -> float:
	return jump_interval + randf_range(-interval_jitter, interval_jitter)
