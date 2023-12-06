extends Node2D

signal debugging

func handle_scene(scene_name):
	emit_signal("debugging",scene_name)
	
func _on_tutorial_pressed():
	handle_scene('Tutorial_fr')

func _on_tutorialPt2_pressed():
	handle_scene('Tutorial pt.2_fr')

func _on_psychicIntro_pressed():
	handle_scene('psychicIntro_fr')

func _on_intrusive0_pressed():
	handle_scene('Intrusive0_fr')

func _on_timeTravelerIntro_pressed():
	handle_scene('timeTravelerIntro_fr')
	
func _on_intrusive1_pressed():
	handle_scene('Intrusive1_fr')

func _on_Gossip_pressed():
	handle_scene('Gossip1_fr')

func _on_intrusive2_pressed():
	handle_scene('Intrusive2_fr')

func _on_fullCast_pressed():
	handle_scene('fullCast_fr')

func _on_Intrusive3_pressed():
	handle_scene('Intrusive3_fr')

func _on_Ending_pressed():
	handle_scene('Ending_fr')
