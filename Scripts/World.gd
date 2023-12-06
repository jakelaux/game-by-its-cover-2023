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
#Translated UI Elements
onready var startButton			= $CanvasLayer2/MenuScreen/VBoxContainer/StartGame
onready var settingsButton		= $CanvasLayer2/MenuScreen/VBoxContainer/Settings
onready var creditsButton		= $CanvasLayer2/MenuScreen/VBoxContainer/Credits
onready var LanguageButton		= $CanvasLayer2/MenuScreen/VBoxContainer/Language
onready var playAgainButton		= $CanvasLayer2/MenuScreen/VBoxContainer2/PlayAgain
onready var creditsTitle		= $CanvasLayer2/MenuScreen/Credits/Title
onready var creditsDetail		= $CanvasLayer2/MenuScreen/Credits/Details
onready var settingsTitle		= $CanvasLayer2/MenuScreen/Settings/Title
onready var settingsMaster		= $CanvasLayer2/MenuScreen/Settings/VBoxContainer/MasterLabel
onready var settingsSFX			= $CanvasLayer2/MenuScreen/Settings/VBoxContainer/SFXLabel
onready var settingsMusic		= $CanvasLayer2/MenuScreen/Settings/VBoxContainer/Music
onready var settingsRadio		= $CanvasLayer2/MenuScreen/Settings/VBoxContainer/StoreRadioLabel

const user_input_scene	= preload("res://Scenes/Utility/userInput.tscn")

var noise_i 		= 0.0
var shake_strength 	= 0.0
var shake			= "SWAY"
var camera_default	= Vector2(0,0)
var dialog
var cur_offset		= Vector2(0,0)
var language		= 'en';
var playback_pos
var ui_lang = {}

func update_lang_en():
	ui_lang.start	 		= 'Start'
	ui_lang.settings 	 	= 'Settings'
	ui_lang.play_again 	 	= 'Return to Menu'
	ui_lang.credits 		= 'Credits'
	ui_lang.master_audio 	= 'Master Audio'
	ui_lang.sound_effects 	= 'Sound Effects'
	ui_lang.music 			= 'Music'
	ui_lang.store_radio 	= 'Store Radio / Background Music'
	ui_lang.language		= 'Language: English'
	ui_lang.credits_title	= 'Credits'
	ui_lang.credits_text	= 'Dev Team\nJacob Laux - Programming, Sound Design, Music, UI, Game Design, Writing\nLiza Goncharova - Art Direction and Lead Artist \nhttps://www.lizarova.com/ | https://www.instagram.com/lizarova.draws/\nWinter Keefer - Story, Writing, & Plot\nShelby Pearson -  Artist\n\n French Localization\nCyriaque Le Menn - Translation\nLucie Teulières - Proofreading\nSasha Boucheron - LQA \n\nAssets / Tools / Inspo\nSadé Robinson - Famicase Entry / Inspiration\nJosh DeMille, Christian Andrews, & Jake Laux - Background Music\nEmi Coppolaemilio - Dialogic\nYui Kinomoto - Glitch Shader'
	
func update_lang_fr():
	ui_lang.start	 		= 'Commencer'
	ui_lang.settings 	 	= 'Paramètres'
	ui_lang.play_again 	 	= 'Retour au menu'
	ui_lang.credits 		= 'Crédits'
	ui_lang.master_audio 	= 'Volume principal'
	ui_lang.sound_effects 	= 'Effets sonores'
	ui_lang.music 			= 'Musique'
	ui_lang.store_radio 	= 'Radio du magasin / Fond sonore'
	ui_lang.language		= 'Langue : Français'
	ui_lang.credits_title	= 'Crédits:'
	ui_lang.credits_text	=  'Équipe de développement\nJacob Laux - Programmation, conception sonore, musique, IU, conception du jeu, écriture\nLiza Goncharova - Direction artistique, artiste principale \nhttps://www.lizarova.com/ | https://www.instagram.com/lizarova.draws/\nWinter Keefer - Scénario, écriture et intrigue\nShelby Pearson -  Artiste\n\n Localisation française\nCyriaque Le Menn - Traduction\nLucie Teulières - Relecture\nSasha Boucheron - LQA \n\nAssets / Outils / Inspiration\nSadé Robinson - Inscription Famicase / Inspiration\nJosh DeMille, Christian Andrews, & Jake Laux - Fond sonore\nEmi Coppolaemilio - Dialogic\nYui Kinomoto - Glitch Shader'

func set_lang():
	startButton.text = ui_lang['start']
	settingsButton.text = ui_lang['settings']
	creditsButton.text = ui_lang['credits']
	LanguageButton.text = ui_lang['language']
	playAgainButton.text = ui_lang['play_again']
	creditsTitle.text = ui_lang['credits_title']
	creditsDetail.text = ui_lang['credits_text']
	settingsTitle.text = ui_lang['settings']
	settingsMaster.text = ui_lang['master_audio']
	settingsSFX.text = ui_lang['sound_effects']
	settingsMusic.text = ui_lang['music']
	settingsRadio.text = ui_lang['store_radio']

func handle_lang_change():
	if language == 'en':
		language = 'fr'
		update_lang_fr()
	elif language == 'fr':
		language = 'en'
		update_lang_en()
	set_lang()

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
	update_lang_en()
	set_lang()
	menu_screen.connect("start_game", self, "start_game")
	menu_screen.connect("play_again", self, "play_again")
	menu_screen.connect('update_language', self, "handle_lang_change")
	menu_screen.connect('debugging', self, 'start_game_debug')
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
	if language == 'en':
		dialog = Dialogic.start('Tutorial')
	elif language == 'fr':
		dialog = Dialogic.start('Tutorial_fr')
	call_deferred("add_child",dialog)
	
func start_game_debug(scene):
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
	dialog = Dialogic.start(scene)
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
	
	####REMOVE ON END DEBUG
	if Input.is_action_just_pressed("escape"):
		show_back_to_menu()
		if is_instance_valid(dialog):
			dialog.queue_free()
			play_again()
	
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
	user_input.update_lang(language)
	var input_box  = user_input.get_node("CanvasLayer/userInput/input")
	if language == 'en':
		input_box.placeholder_text = "What's my name again?"
	elif language == 'fr':
		input_box.placeholder_text = "Je m'appelle…"
	user_input.connect('user_input_completed',self,"update_user_name")
	get_tree().root.add_child(user_input)

func update_user_name(name):
	Dialogic.set_variable('player_name',name)
	var timeline
	if language == 'en':
		timeline = 'Tutorial pt.2'
	elif language == 'fr':
		timeline = 'Tutorial pt.2_fr'
	var tutorial_2 = Dialogic.start(timeline)
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
