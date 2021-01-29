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
var m_m_s_i = "res://Data/mapMouseScrollIndexes.json"
# Instances
var adventure_map
var groundTileMap
var movementTileMap
var camera
var info
var m_m_s_i_
# Other
var mapWidth
var mapHeight
var pointerState = 0
var map_move_pointers = []
var pointers = []
var move_vector = Vector2(0, 0)

func _ready():
	adventure_map = get_node("/root/AdventureMap")
	groundTileMap = get_node("../TM-Ground")
	movementTileMap = get_node("../TM-Movement")
	camera = get_node("../Camera2D")
	info = get_node("../UI/InfoPanel/info")
	m_m_s_i_ = adventure_map.loadFilePayload(m_m_s_i)
	map_move_pointers.append(m_p_scroll_up)
	map_move_pointers.append(m_p_scroll_down)
	map_move_pointers.append(m_p_scroll_left)
	map_move_pointers.append(m_p_scroll_right)
	map_move_pointers.append(m_p_scroll_up_left)
	map_move_pointers.append(m_p_scroll_up_right)
	map_move_pointers.append(m_p_scroll_down_left)
	map_move_pointers.append(m_p_scroll_down_right)
	pointers.append(m_pointer_go)
	pointers.append(m_pointer_blocked)
	pointers.append(m_pointer_interact)
	pointers.append(m_pointer_ui)

func _process(delta):
	var mouse_pos_global = get_global_mouse_position()
	var mouse_pos_local = get_viewport().get_mouse_position()
	var tile = groundTileMap.world_to_map(mouse_pos_global)
	var land_mass = movementTileMap.getLandMassOfCell(tile.x, tile.y)
	
	info.set_text("Coordinates: %s \nLand Mass: %s" % [tile, land_mass])
	
	if pointerState == 5:
		return
	
	if mouse_pos_local.x < 10 || mouse_pos_local.x > camera.viewport_size.x - 10 || mouse_pos_local.y < 10 || mouse_pos_local.y > camera.viewport_size.y - 10:
		move_vector = Vector2()
		if mouse_pos_local.x < 10 && camera.position.x - camera.w_h_times_zoom > camera.limit_left:
			move_vector.x = -1
		elif mouse_pos_local.x > camera.viewport_size.x - 10 && camera.position.x + camera.w_h_times_zoom < camera.limit_right:
			move_vector.x = 1
		if mouse_pos_local.y < 10 && camera.position.y - camera.h_h_times_zoom > camera.limit_top:
			move_vector.y = -1
		elif mouse_pos_local.y > camera.viewport_size.y - 10 && camera.position.y + camera.h_h_times_zoom < camera.limit_bottom:
			move_vector.y = 1
		
		var mouse_cursor_index = m_m_s_i_.get(String(move_vector.x)).get(String(move_vector.y))
		if mouse_cursor_index != null:
			Input.set_custom_mouse_cursor(map_move_pointers[mouse_cursor_index])
			pointerState = -1

		camera.scrollCamera(move_vector, delta)

func _unhandled_input(event):
	if event is InputEventMouse:
		var c_s_a
		if adventure_map.current_selection_instance.travel_type != -1:
			c_s_a = adventure_map.current_selection_instance
		else:
			Input.set_custom_mouse_cursor(m_pointer_interact)
			pointerState = 2
			return
		var tile = groundTileMap.world_to_map(get_global_mouse_position())
		var move_tile = movementTileMap.get_cell(tile.x, tile.y)
#		var selected_land_mass
#		if tile.x >= 0 && tile.x < mapWidth && tile.y >= 0 && tile.y < mapHeight:
#			selected_land_mass = movementTileMap.getLandMassOfCell(tile.x, tile.y)
#		else:
#			selected_land_mass = 0
		var selected_land_mass = movementTileMap.getLandMassOfCell(tile.x, tile.y)
		var army_present = adventure_map.getArmyPresent(tile)
		var interactable_present = adventure_map.propsTileMap.checkIfTileHasInteractable(tile)
		var player_explored_masses = adventure_map.current_player_instance.explored_masses
		var is_tile_explored = adventure_map.current_player_instance.my_explored_tiles.find(tile)
		var tile_explored_mass = -1
		if is_tile_explored > -1:
			tile_explored_mass = adventure_map.current_player_instance.getTileExploredMass(tile)
		var is_path_to_tile_explored = false
		if c_s_a.my_explored_mass == tile_explored_mass:
			is_path_to_tile_explored = true
		
		if move_tile == 0 && selected_land_mass == c_s_a.current_land_mass:
			if is_path_to_tile_explored == true:
				if army_present == true || interactable_present != null:
					if tile.x == c_s_a.my_coords.x && tile.y == c_s_a.my_coords.y:
						Input.set_custom_mouse_cursor(m_pointer_ui)
						pointerState = 3
					else:
						Input.set_custom_mouse_cursor(m_pointer_interact)
						pointerState = 2
				else:
					Input.set_custom_mouse_cursor(m_pointer_go)
					pointerState = 0
			else:
				Input.set_custom_mouse_cursor(m_pointer_blocked)
				pointerState = 1
		elif move_tile == 1 || selected_land_mass != c_s_a.current_land_mass:
			Input.set_custom_mouse_cursor(m_pointer_blocked)
			pointerState = 1
		elif move_tile == 3:
			Input.set_custom_mouse_cursor(m_pointer_interact)
			pointerState = 2

func setMouseState(new_pointer_state):
	if pointerState == 5 && new_pointer_state != -1:
		return
	pointerState = new_pointer_state
	match pointerState:
		5:
			Input.set_custom_mouse_cursor(pointers[new_pointer_state - 2])
		4:
			Input.set_custom_mouse_cursor(pointers[new_pointer_state - 1])
		-1:
			Input.set_custom_mouse_cursor(pointers[0])
		_:
			Input.set_custom_mouse_cursor(pointers[new_pointer_state])
