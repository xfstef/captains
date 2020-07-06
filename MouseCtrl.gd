extends Node2D

# Preloaded Resources
var m_pointer_go = preload("res://Assets/Sprites/pointerGo.png")
var m_pointer_blocked = preload("res://Assets/Sprites/pointerBlocked.png")
var m_pointer_interact = preload("res://Assets/Sprites/pointerInteract.png")
var m_pointer_ui = preload("res://Assets/Sprites/pointerUI.png")
var m_p_scroll_up = preload("res://Assets/Sprites/scrollUp.png")
var m_p_scroll_down = preload("res://Assets/Sprites/scrollDown.png")
var m_p_scroll_left = preload("res://Assets/Sprites/scrollLeft.png")
var m_p_scroll_right = preload("res://Assets/Sprites/scrollRight.png")
var m_p_scroll_up_left = preload("res://Assets/Sprites/scrollUL.png")
var m_p_scroll_up_right = preload("res://Assets/Sprites/scrollUR.png")
var m_p_scroll_down_left = preload("res://Assets/Sprites/scrollDL.png")
var m_p_scroll_down_right = preload("res://Assets/Sprites/scrollDR.png")
# Instances
var adventure_map
var groundTileMap
var movementTileMap
var camera
var info
# Other
var mapWidth
var mapHeight

func _ready():
	adventure_map = get_node("/root/AdventureMap")
	groundTileMap = get_node("../TM-Ground")
	movementTileMap = get_node("../TM-Movement")
	camera = get_node("../Camera2D")
	info = get_node("../UI/info")

func _process(delta):
	var mouse_pos_global = get_global_mouse_position()
	var mouse_pos_local = get_viewport().get_mouse_position()
	var tile = groundTileMap.world_to_map(mouse_pos_global)
	var move_tile = movementTileMap.get_cell(tile.x, tile.y)
	var selected_land_mass
	
	if tile.x >= 0 && tile.x < mapWidth && tile.y >= 0 && tile.y < mapHeight:
		selected_land_mass = adventure_map.landMassesMatrix[tile.x][tile.y]
	else:
		selected_land_mass = 0
	
	var c_s_a = adventure_map.army_instances[adventure_map.selected_army.x][adventure_map.selected_army.y]
	
	if mouse_pos_local.x < 30 || mouse_pos_local.x > camera.viewport_size.x - 30 || mouse_pos_local.y < 30 || mouse_pos_local.y > camera.viewport_size.y - 30:
		var move_vector = Vector2()
		if mouse_pos_local.x < 30 && camera.position.x - camera.w_h_times_zoom > camera.limit_left:
			move_vector.x = -1
		elif mouse_pos_local.x > camera.viewport_size.x - 30 && camera.position.x + camera.w_h_times_zoom < camera.limit_right:
			move_vector.x = 1
		if mouse_pos_local.y < 30 && camera.position.y - camera.h_h_times_zoom > camera.limit_top:
			move_vector.y = -1
		elif mouse_pos_local.y > camera.viewport_size.y - 30 && camera.position.y + camera.h_h_times_zoom < camera.limit_bottom:
			move_vector.y = 1
		
		if move_vector.x > 0:
			if move_vector.y > 0:
				Input.set_custom_mouse_cursor(m_p_scroll_down_right)
			elif move_vector.y < 0:
				Input.set_custom_mouse_cursor(m_p_scroll_up_right)
			else:
				Input.set_custom_mouse_cursor(m_p_scroll_right)
		elif move_vector.x == 0:
			if move_vector.y > 0:
				Input.set_custom_mouse_cursor(m_p_scroll_down)
			elif move_vector.y < 0:
				Input.set_custom_mouse_cursor(m_p_scroll_up)
		elif move_vector.x < 0:
			if move_vector.y > 0:
				Input.set_custom_mouse_cursor(m_p_scroll_down_left)
			elif move_vector.y < 0:
				Input.set_custom_mouse_cursor(m_p_scroll_up_left)
			else:
				Input.set_custom_mouse_cursor(m_p_scroll_left)
		camera.scrollCamera(move_vector, delta)
		
	elif tile.x == c_s_a.my_coords.x && tile.y == c_s_a.my_coords.y:
		Input.set_custom_mouse_cursor(m_pointer_ui)
	elif move_tile == 0 && selected_land_mass == c_s_a.current_land_mass:
		Input.set_custom_mouse_cursor(m_pointer_go)
	elif move_tile == 1 || selected_land_mass != c_s_a.current_land_mass:
		Input.set_custom_mouse_cursor(m_pointer_blocked)
	elif move_tile == 2 || selected_land_mass != c_s_a.current_land_mass:
		Input.set_custom_mouse_cursor(m_pointer_blocked)
	elif move_tile == 3:
		Input.set_custom_mouse_cursor(m_pointer_interact)
	
	var text = "tile: %s, pos: %s" % [tile, mouse_pos_global]
	info.set_text(text)
