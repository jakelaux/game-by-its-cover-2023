extends Node2D

export var SHAKE_DECAY          = 5.0
export var NOISE_SHAKE_SPEED    = 15.0
export var NOISE_SHAKE_STRENGTH = 30.0
export var NOISE_SWAY_SPEED     = .5
export var NOISE_SWAY_STRENGTH  = 5.0

onready var camera				= $GameCamera
onready var menu_camera			= $MenuCamera
onready var blur				= $Shaders/BlurShader
onready var glitch				= $Shaders/GlitchShader
onready var wiggle				= $Shaders/ScreenNoiseShader
onready var sanity				= $Shaders/SanityShader
onready var sanity_timer		= $SanityTimer
onready var radio				= $Radio
onready var background			= $Background
onready var tween				= $Tween
onready var menu_screen			= $CanvasLayer2/MenuScreen
onready var menu				= $CanvasLayer2/MenuScreen/VBoxContainer
onready var back_to_menu		= $CanvasLayer2/MenuScreen/VBoxContainer2
onready var noise				= OpenSimplexNoise.new()
onready var rand				= RandomNumberGenerator.new()
onready var endings_canvas		= $Background/endings
onready var ending1				= $Background/endings/ending1
onready var ending2				= $Background/endings/ending2
onready var ending3				= $Background/endings/ending3
onready var intrusive_music		= $GameMusicManager/IntrusiveMusic
onready var ending_music_fire	= $GameMusicManager/EndingMusicFire
onready var ending_music		= $GameMusicManager/EndingMusic
onready var game_ambient_music	= $GameMusicManager/GameAmbientMusic
onready var title				= $AnimationPlayer
onready var title_off			= $AnimationPlayer/off
onready var title_on			= $AnimationPlayer/on
onready var game_comp			= $AnimationPlayer/gamecomp
onready var ending_animation	= $Background/AnimationPlayer

const user_input_scene	= preload("res://Scenes/Utility/userInput.tscn")

var noise_i 		= 0.0
var shake_strength 	= 0.0
var shake			= "SWAY"
var camera_default	= Vector2(0,0)
var dialog
var cur_offset		= Vector2(0,0)
var playback_pos

func _ready():
	rand.randomize()
	camera_default = camera.position
	noise.seed = rand.randi()
	noise.period = 2
	camera.current = false
	camera.visible = false
	menu_camera.current = true
	menu_camera.visible = true
	game_ambient_music.play()
	menu_screen.connect("start_game", self, "start_game")
	menu_screen.connect("play_again", self, "play_again")
	title.play("FlickerOn")
	
func start_game():
	menu_camera.current = false
	menu_camera.visible = false
	title_off.visible = false
	title_on.visible = false
	game_comp.visible = false
	camera.current = true
	camera.visible = true
	menu_screen.visible = false
	background.modulate.a = 0.0
	start_fade_in(background)
	radio.start_radio()
	dialog = Dialogic.start('Tutorial')
	call_deferred("add_child",dialog)
	
func call_ending(ending):
	game_ambient_music.stop()
	intrusive_music.stop()
	radio.pause_radio()
	endings_canvas.visible = true
	if ending == 'ending1' || ending == 'ending2':
		ending_music_fire.play()
		if ending == 'ending1':
			ending1.visible = true
			ending_animation.play("Ending1")
		else:
			ending2.visible = true
			ending_animation.play("Ending2")
	elif ending == 'ending3':
		ending_animation.play("Ending3")
		ending3.visible = true
		ending_music.play()
	
func show_back_to_menu():
	menu_camera.current = true
	menu_camera.visible = true
	camera.current = false
	camera.visible = false
	menu_screen.visible = true
	title_off.visible = true
	title_on.visible = true
	game_comp.visible = true
	menu.visible = false
	back_to_menu.visible = true
	
func play_again():
	Dialogic.set_variable('player_name','')
	Dialogic.set_variable('tarot_card','')
	Dialogic.set_variable('pres_year','')
	Dialogic.set_variable('can_have_key','')
	Dialogic.set_variable('investigate_bathroom','')
	Dialogic.set_variable('key_broken','false')
	Dialogic.set_variable('is_tea_spilled','no')
	Dialogic.set_variable('made_videogame','no')
	Dialogic.set_variable('becky_var','neutral')
	Dialogic.set_variable('ending','')
	endings_canvas.visible = false
	ending1.visible = false
	ending2.visible = false
	ending3.visible = false
	back_to_menu.visible = false
	menu.visible = true
	ending_music.stop()
	ending_music_fire.stop()
	game_ambient_music.play()

func start_fade_in(background_image):
	tween.interpolate_property(background_image, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 1.0, Tween.TRANS_LINEAR)
	tween.start()

func _process(delta):
	shake_strength = lerp(shake_strength,0,SHAKE_DECAY*delta)
	var shake_offset: Vector2
	if shake == "SWAY":
		shake_offset = get_noise_offset(delta, NOISE_SWAY_SPEED, NOISE_SWAY_STRENGTH)
	elif shake == "SHAKE":
		shake_offset = get_noise_offset(delta, NOISE_SHAKE_SPEED, NOISE_SHAKE_STRENGTH)
	camera.offset = shake_offset
	cur_offset = shake_offset
	if Input.is_action_just_pressed("ui_page_down"):
		damage_sanity()
	
func damage_sanity():
	shake = "SHAKE"
	sanity_timer.start()
	intrusive_thought()
	playback_pos = game_ambient_music.get_playback_position()
	game_ambient_music.stop()
	radio.pause_radio()
	if !intrusive_music.is_playing():
		intrusive_music.play()

func apply_shake():
	shake_strength = NOISE_SHAKE_STRENGTH
	
func get_noise_offset(delta,speed,strength):
	noise_i += delta * speed
	return Vector2(
		noise.get_noise_2d(1,noise_i)*strength,
		noise.get_noise_2d(100,noise_i)*strength
	)

func get_shake_offset():
	return cur_offset

func player_name_capture():
	var user_input = user_input_scene.instance()
	var input_box  = user_input.get_node("CanvasLayer/userInput/input")
	input_box.placeholder_text = "What's my name again?"
	user_input.connect('user_input_completed',self,"update_user_name")
	get_tree().root.add_child(user_input)

func update_user_name(name):
	Dialogic.set_variable('player_name',name)
	var tutorial_2 = Dialogic.start('Tutorial pt.2')
	dialog = tutorial_2
	add_child(tutorial_2)

func intrusive_thought():
	glitch.visible = true
	sanity.visible = true

func end_intrusive_thought():
	glitch.visible = false
	sanity.visible = false
	intrusive_music.stop()
	radio.play_radio()
	game_ambient_music.play(playback_pos)

func blur_vision():
	blur.visible = true

func unblur_vision():
	blur.visible = false

func _on_SanityTimer_timeout():
	shake = "SWAY"
