# Game.gd
extends Node

@export var start_score: int = 0
var score: int
var dying := false

func _ready() -> void:
	score = start_score
	_update_hud()

func add_score(amount: int = 1) -> void:
	score += amount
	_update_hud()

func on_player_death() -> void:
	if dying: return
	dying = true
	score = max(0, score - 1)
	_update_hud()
	get_tree().reload_current_scene()
	dying = false

func _update_hud() -> void:
	var hud := get_tree().get_first_node_in_group("hud")
	if hud:
		hud.call("set_score", score)
