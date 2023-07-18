extends Node2D

signal user_input_completed

onready var user_input	= $userInput
onready var input		= $userInput/input
onready var validation	= $validation
onready var label		= $validation/label

func _on_waitForFade_timeout():
	user_input.visible = true

func _on_input_text_entered(new_text):
	user_input.visible = false
	validation.visible = true
	label.text = "is " + new_text + " correct?"
	
func _on_Yes_pressed():
	validation.visible = false
	user_input.visible = false
	emit_signal("user_input_completed",input.text)
	call_deferred("queue_free")

func _on_No_pressed():
	print("no it's not right")
	validation.visible = false
	user_input.visible = true
