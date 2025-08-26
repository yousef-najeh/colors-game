extends Node

var message_label: Label
var chat: NobodyWhoChat

func _ready() -> void:
	var main_scene = get_tree().current_scene
	if main_scene:
		chat = main_scene.find_child("NobodyWhoChat", true, false)
		if not chat:
			print("Warning: NobodyWhoChat node not found in the current scene! Check the scene tree.")
			print("Current scene name: ", main_scene.name)
			print("Scene children: ", main_scene.get_children())
		else:
			print("NobodyWhoChat found at: ", chat.get_path())

func register_label(label: Label) -> void:
	message_label = label

func show_message(event: String) -> void:
	var response = await get_ai_response(event)
	print("Full response: ", response)  
	if message_label:
		message_label.text = response.split("\n")[0]  

func get_ai_response(event: String) -> String:
	if not chat:
		return "AI not initialized!"
	chat.say("Event: " + event)
	var response = await chat.response_finished
	return response
