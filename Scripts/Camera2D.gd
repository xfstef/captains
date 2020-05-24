extends Camera2D

var width_half
var height_half
var zoom_dif_h
var zoom_dif_v
var viewport_size
var w_h_times_zoom
var h_h_times_zoom

func _ready():
	viewport_size = get_viewport().size
	width_half = viewport_size.x / 2
	height_half = viewport_size.y / 2
	w_h_times_zoom = width_half * self.zoom.x
	h_h_times_zoom = height_half * self.zoom.y

func _process(delta):
	var move_vector = Vector2()
	var mouse_pos = get_viewport().get_mouse_position()
	
	if Input.is_action_pressed("map_left") && self.position.x - w_h_times_zoom > self.limit_left:
		move_vector.x -= 1
	elif Input.is_action_pressed("map_right") && self.position.x + w_h_times_zoom < self.limit_right:
		move_vector.x += 1
	if Input.is_action_pressed("map_up") && self.position.y - h_h_times_zoom > self.limit_top:
		move_vector.y -= 1
	elif Input.is_action_pressed("map_down") && self.position.y + h_h_times_zoom < self.limit_bottom:
		move_vector.y += 1
	if Input.is_action_just_released("wheel_down") && self.zoom.x < 1.5:
		self.zoom.x += 0.25
		self.zoom.y += 0.25
		viewport_size = get_viewport().size
		w_h_times_zoom = width_half * self.zoom.x
		h_h_times_zoom = height_half * self.zoom.y
		#Checks if after zooming out the camera is now outside its limits horizontally
		if self.position.x - w_h_times_zoom < self.limit_left:
			zoom_dif_h = self.limit_left + (self.position.x - w_h_times_zoom) * -1
			self.position.x += zoom_dif_h
		elif self.position.x + w_h_times_zoom > self.limit_right:
			zoom_dif_h = self.position.x + w_h_times_zoom - self.limit_right
			self.position.x -= zoom_dif_h
		#Checks if after zooming out the camera is now outside its limits vertically	
		if self.position.y - h_h_times_zoom < self.limit_top:
			zoom_dif_v = self.limit_top + (self.position.y - h_h_times_zoom) * -1
			self.position.y += zoom_dif_v
		elif self.position.y + h_h_times_zoom > self.limit_bottom:
			zoom_dif_v = self.position.y + h_h_times_zoom - self.limit_bottom
			self.position.y -= zoom_dif_v
	elif Input.is_action_just_released("wheel_up") && self.zoom.x > 0.5:
		self.zoom.x -= 0.25
		self.zoom.y -= 0.25
		viewport_size = get_viewport().size
		w_h_times_zoom = width_half * self.zoom.x
		h_h_times_zoom = height_half * self.zoom.y
	
	if mouse_pos.x < 30 && self.position.x - w_h_times_zoom > self.limit_left:
		move_vector.x = -1
	elif mouse_pos.x > viewport_size.x - 30 && self.position.x + w_h_times_zoom < self.limit_right:
		move_vector.x = 1
	if mouse_pos.y < 30 && self.position.y - h_h_times_zoom > self.limit_top:
		move_vector.y = -1
	elif mouse_pos.y > viewport_size.y - 30 && self.position.y + h_h_times_zoom < self.limit_bottom:
		move_vector.y = 1
	
	global_translate(move_vector * delta * 300 * self.zoom.x)
