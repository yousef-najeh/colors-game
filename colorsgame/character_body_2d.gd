extends CharacterBody2D

@export var speed: float = 200.0
@export var jump_force: float = -400.0
@export var gravity: float = 900.0

var score: int = 0
var lives: int = 3

@onready var anim_sprite = $AnimatedSprite2D
@onready var score_label = $"../UI/ScoreLabel"
@onready var lives_label = $"../UI/LivesLabel"

func _physics_process(delta: float) -> void:
	var direction = Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * speed

	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		if Input.is_action_just_pressed("ui_accept"):
			velocity.y = jump_force

	# تحريك اللاعب
	move_and_slide()

	# تشغيل الأنيميشن
	if direction != 0:
		anim_sprite.play("run")
		anim_sprite.flip_h = direction < 0
	else:
		anim_sprite.play("idle")

# الاصطدام مع Burger و Cup
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Burger"):
		score += 1
		body.queue_free()
		update_ui()

	elif body.is_in_group("Cup"):
		lives += 1
		body.queue_free()
		update_ui()

func update_ui() -> void:
	score_label.text = "Score: " + str(score)
	lives_label.text = "Lives: " + str(lives)


func _on_cup_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_candy_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
