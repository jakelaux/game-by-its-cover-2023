extends Camera2D

export var pan_speed 	  = 50
export var pan_area_size  = 25
export var recenter_speed = 100

onready var background 		  = $"../Background"
onready var background_center = $"../Background/BackgroundCenter"

var viewport_rect: 		 Rect2
var background_rect: 	 Rect2
var background_position: Vector2
var reset_camera: 		 Vector2
var camera_x: float
var camera_y: float

func _ready():
	viewport_rect 	    = get_viewport_rect()
	background_rect     = background.get_rect()
	background_position = background.get_global_position()
	reset_camera 		= position
	
func _process(delta):
	var input_vector = Vector2.ZERO
	var mouse_pos = get_viewport().get_mouse_position()
	if mouse_pos.x > viewport_rect.size.x - pan_area_size:
		input_vector.x += 1
	if mouse_pos.x < pan_area_size:
		input_vector.x -= 1
	if mouse_pos.y > viewport_rect.size.y - pan_area_size:
		input_vector.y += 1
	if mouse_pos.y < pan_area_size:
		input_vector.y -= 1
	if  mouse_pos.x < viewport_rect.size.x - pan_area_size && mouse_pos.x > pan_area_size && mouse_pos.y < viewport_rect.size.y - pan_area_size && mouse_pos.y > pan_area_size:
		recenter_camera()
	else:
		pan_camera(input_vector * delta * pan_speed)

func pan_camera(pan_vector: Vector2):
	var camera_rect = Rect2(position - viewport_rect.size / 2, viewport_rect.size)
	var min_x = background_rect.position.x
	var max_x = background_rect.position.x + (background_rect.size.x * background.rect_scale.x) - camera_rect.size.x
	var min_y = background_rect.position.y
	var max_y = background_rect.position.y + (background_rect.size.y * background.rect_scale.y) - camera_rect.size.y
	camera_rect.position += pan_vector
	camera_rect.position.x = clamp(camera_rect.position.x, min_x, max_x)
	camera_rect.position.y = clamp(camera_rect.position.y, min_y, max_y)
	position = camera_rect.position + camera_rect.size / 2

func recenter_camera():
	var tween = get_node("Tween")
	tween.stop(self, "position")
	tween.interpolate_property(self, "position", position, background_center.get_global_position(), 0.04, Tween.TRANS_EXPO)
	tween.start()
	
