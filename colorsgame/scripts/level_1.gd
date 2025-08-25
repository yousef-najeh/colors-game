extends Node2D

var score : int = 0

@export var score_display: Label

func _on_burger_body_entered(body):
		if body.is_in_group("player") :
			score += 1
			print(score)
			score_display.text= str("SCORE : ",score)



func _on_donat_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") :
			score -= 1
			if (score < 0):
				score = 0
			print(score)
			score_display.text= str("SCORE : ",score)
			
			


func _on_killzone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") :
		score =0 
		score_display.text = str("SCORE : ", score)
		
		
