extends Camera2D

func _process(delta):
	var move_vector = Vector2()
	var mouse_pos = get_viewport().get_mouse_position()
	var viewport_size = get_viewport().size
	
	if Input.is_action_pressed("map_left"):
		move_vector.x -= 1
	elif Input.is_action_pressed("map_right"):
		move_vector.x += 1
	if Input.is_action_pressed("map_up"):
		move_vector.y -= 1
	elif Input.is_action_pressed("map_down"):
		move_vector.y += 1
	if Input.is_action_just_released("wheel_down") && self.zoom.x < 1.5:
		self.zoom.x += 0.25
		self.zoom.y += 0.25
	elif Input.is_action_just_released("wheel_up") && self.zoom.x > 0.5:
		self.zoom.x -= 0.25
		self.zoom.y -= 0.25
	
	if mouse_pos.x < 30:
		move_vector.x = -1
	elif mouse_pos.x > viewport_size.x - 30:
		move_vector.x = 1
	if mouse_pos.y < 30:
		move_vector.y = -1
	elif mouse_pos.y > viewport_size.y - 30:
		move_vector.y = 1
	
	global_translate(move_vector * delta * 300 * self.zoom.x)
