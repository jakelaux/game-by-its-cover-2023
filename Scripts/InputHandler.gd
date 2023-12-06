extends Node2D

signal user_input_completed

onready var user_input	= $CanvasLayer/userInput
onready var input		= $CanvasLayer/userInput/input
onready var validation	= $CanvasLayer/validation
onready var label		= $CanvasLayer/validation/label
onready var yes			= $CanvasLayer/validation/HBoxContainer/Yes
onready var no			= $CanvasLayer/validation/HBoxContainer/No

var lang = 'en'

func _on_waitForFade_timeout():
	user_input.visible = true

func _on_input_text_entered(new_text):
	user_input.visible = false
	validation.visible = true
	if lang == 'en':
		label.text = "Is " + new_text + " correct?"
		yes.text = "Yes"
		no.text = "No"
	elif lang == 'fr':
		label.text = new_text + ", c'est bien ça ?"
		yes.text = "Oui"
		no.text = "Non"
func _on_Yes_pressed():
	validation.visible = false
	user_input.visible = false
	emit_signal("user_input_completed",input.text)
	call_deferred("queue_free")

func _on_No_pressed():
	validation.visible = false
	user_input.visible = true

func update_lang(new_lang):
	lang = new_lang
