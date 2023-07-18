extends TextureRect

func _process(delta: float) -> void:
	 # Get the mouse position in global coordinates
	var mouse_position = get_global_mouse_position()
	
	# Convert the mouse position to UV coordinates
	var viewport = get_viewport_rect()
	var uv = mouse_position / viewport.size
	
	# Set the mouse position uniform in the shader material
	var material = get_material()
	if material:
		material.set_shader_param("mouse_position", uv)
