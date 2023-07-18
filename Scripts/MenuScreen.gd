extends Control

signal start_game

onready var credits  = $Credits
onready var settings = $Settings 

var master_bus = AudioServer.get_bus_index("Master")
var sfx_bus	   = AudioServer.get_bus_index("SFX")
var radio_bus  = AudioServer.get_bus_index("Radio")
var music_bus  = AudioServer.get_bus_index("GameMusic")

func handle_audio_bus_change(bus,value):
	AudioServer.set_bus_volume_db(bus,value)
	if value == -30:
		AudioServer.set_bus_mute(bus,true)
	else:
		AudioServer.set_bus_mute(bus,false)

func _on_StartGame_pressed():
	emit_signal("start_game")

func _on_Settings_pressed():
	settings.visible = true

func _on_Credits_pressed():
	credits.visible = true

func _on_CloseCredits_pressed():
	credits.visible = false

func _on_CloseSettings_pressed():
	settings.visible = false

func _on_MasterAudio_value_changed(value):
	handle_audio_bus_change(master_bus,value)
	
func _on_SoundEffects_value_changed(value):
	handle_audio_bus_change(sfx_bus,value)

func _on_StoreRadio_value_changed(value):
	handle_audio_bus_change(radio_bus,value)

func _on_GameMusic_value_changed(value):
	handle_audio_bus_change(music_bus,value)
