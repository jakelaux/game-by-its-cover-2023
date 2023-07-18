extends Node2D

export var SHAKE_DECAY          = 5.0
export var NOISE_SHAKE_SPEED    = 15.0
export var NOISE_SHAKE_STRENGTH = 30.0
export var NOISE_SWAY_SPEED     = 1
export var NOISE_SWAY_STRENGTH  = 9.0

onready var camera			= $GameCamera
onready var menu_camera		= $MenuCamera
onready var blur			= $Shaders/BlurShader
onready var glitch			= $Shaders/GlitchShader
onready var wiggle			= $Shaders/ScreenNoiseShader
onready var sanity			= $Shaders/SanityShader
onready var sanity_timer	= $SanityTimer
onready var radio			= $Radio
onready var background		= $Background
onready var tween			= $Tween
onready var menu_screen		= $MenuScreen
onready var noise			= OpenSimplexNoise.new()
onready var rand			= RandomNumberGenerator.new()

const tutorial		= preload("res://Scenes/Tutorial/Tutorial.tscn")

var noise_i 		= 0.0
var shake_strength 	= 0.0
var shake			= "SWAY"
var camera_default	= Vector2(0,0)

#Player State Defaults

func _ready():
	rand.randomize()
	camera_default = camera.position
	noise.seed = rand.randi()
	noise.period = 2
	camera.current = false
	menu_camera.current = true
	menu_screen.connect("start_game", self, "start_game")

func start_game():
	menu_camera.current = false
	camera.current = true
	menu_screen.visible = false
	var tutorial_instance = tutorial.instance()
	background.visible = true
	background.modulate.a = 0.0
	start_fade_in(background)
	radio.start_radio()
	tutorial_instance.connect('tutorial_completed',self,"close_tutorial")
	call_deferred("add_child",tutorial_instance)

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
	if Input.is_action_just_pressed("ui_page_down"):
		damage_sanity()
	
func damage_sanity():
	shake = "SHAKE"
	glitch.visible = true
	sanity.visible = true
	sanity_timer.start()
	
func close_tutorial():
	var tutorial_2 = Dialogic.start('Tutorial pt.2')
	add_child(tutorial_2)

func apply_shake():
	shake_strength = NOISE_SHAKE_STRENGTH
	
func get_noise_offset(delta,speed,strength):
	noise_i += delta * speed
	return Vector2(
		noise.get_noise_2d(1,noise_i)*strength,
		noise.get_noise_2d(100,noise_i)*strength
	)

func _on_SanityTimer_timeout():
	shake = "SWAY"
	glitch.visible = false
	sanity.visible = false
