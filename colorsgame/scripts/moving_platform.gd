extends StaticBody2D

@export var speed: float = 60.0                 # سرعة الحركة
@export var start_towards_right: bool = true    # تبدأ باتجاه اليمين؟
@export var turn_pause: float = 0.12            # توقف بسيط عند الأطراف (0 لتعطيله)
@export var lock_vertical: bool = true          # قفل الارتفاع (Y) أفقيًا فقط

@export var left_marker_path: NodePath          # اسحبي Marker2D (اليسار)
@export var right_marker_path: NodePath         # اسحبي Marker2D (اليمين)

var _dir := 1
var _pause_t := 0.0
@onready var _left: Marker2D  = get_node_or_null(left_marker_path)  as Marker2D
@onready var _right: Marker2D = get_node_or_null(right_marker_path) as Marker2D
@onready var _base_y: float   = global_position.y

func _ready() -> void:
	# fallback: لو ما تعرّفوا من الـInspector، جرّبي أسماء شائعة
	if _left == null:  _left  = (get_node_or_null("Left")  as Marker2D)  if has_node("Left")  else null
	if _right == null: _right = (get_node_or_null("Right") as Marker2D)  if has_node("Right") else null

	if _left == null or _right == null:
		push_error("Assign left_marker_path / right_marker_path (Marker2D).")
		return

	_dir = 1 if start_towards_right else -1

func _physics_process(delta: float) -> void:
	if _left == null or _right == null:
		return

	# إيقاف مؤقت عند الأطراف
	if _pause_t > 0.0:
		_pause_t -= delta
		constant_linear_velocity = Vector2.ZERO
		return

	# حددي الهدف حسب الاتجاه الحالي
	var target_x := (_right.global_position.x if _dir > 0 else _left.global_position.x)
	var target := Vector2(target_x, (_base_y if lock_vertical else global_position.y))

	# تحريك + حمل اللاعب (سرعة المنصّة)
	var prev := global_position
	global_position = global_position.move_toward(target, speed * delta)
	constant_linear_velocity = (global_position - prev) / delta

	# عند الوصول للطرف بدّل الاتجاه
	if abs(global_position.x - target_x) <= 1.0:
		_dir *= -1
		_pause_t = turn_pause
