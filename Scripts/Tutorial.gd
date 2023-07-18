extends Node2D

signal tutorial_completed

onready var dialog	= $Dialog
 
const user_input_scene = preload("res://Scenes/Utility/userInput.tscn")

func _on_Dialog_dialogic_signal(value):
	match value:
		"player_name_capture":
			var user_input = user_input_scene.instance()
			var input_box  = user_input.get_node("userInput/input")
			input_box.placeholder_text = "What's my name again?"
			user_input.connect('user_input_completed',self,"update_user_name")
			get_tree().root.add_child(user_input)

func update_user_name(name):
	Dialogic.set_variable('player_name',name)
	emit_signal("tutorial_completed")
	call_deferred("queue_free")
