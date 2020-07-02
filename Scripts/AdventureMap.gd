extends Node2D

# Paths
var mapPath = "res://Maps/test4.json"
var interactablesPath = "res://Data/mapInteractables.json"
# Preloaded resources
var m_pointer_go = preload("res://Assets/Sprites/pointerGo.png")
var m_pointer_blocked = preload("res://Assets/Sprites/pointerBlocked.png")
# Other
var mapGroundMatrix = []
var mapPropsMatrix = []
var mapMovementMatrix = []
var info
var mapWidth = 0
var mapHeight = 0
var groundTileMap
var propsTileMap
var movementTileMap
var camera
var armyNode
var playersArmies = []
var army_instances = []
var selected_army = Vector2()
var command_given = false

# Called when the node enters the scene tree for the first time.
func _ready():
	camera = get_node("Camera2D")
	groundTileMap = get_node("TM-Ground")
	propsTileMap = get_node("TM-Props")
	movementTileMap = get_node("TM-Movement")
	info = get_node("UI/info")
	armyNode = get_node("Army")
	loadMapData()

func prepCamera():
	var half_width_pixels = (mapWidth / 2) * 144
	camera.limit_left = (half_width_pixels * -1) - 200
	camera.limit_top = -120
	camera.limit_right = half_width_pixels + 200
	camera.limit_bottom = mapHeight * 72 + 192

func loadFilePayload(fileName):
	var file = File.new()
	if not file.file_exists(fileName):
		return
	file.open(fileName, File.READ)
	var payload = parse_json(file.get_as_text())
	file.close()
	return payload

func loadMapData():
	var payload = loadFilePayload(mapPath)
	mapWidth = payload.width
	mapHeight = payload.height
	prepCamera()
	
	for x in range(mapHeight):
		mapGroundMatrix.append([])
		mapGroundMatrix[x] = []
		mapPropsMatrix.append([])
		mapPropsMatrix[x] = []
		mapMovementMatrix.append([])
		mapMovementMatrix[x] = []
		for y in range(mapWidth):
			mapGroundMatrix[x].append([])
			mapGroundMatrix[x][y] = payload.tiles[x][y][0]
			mapPropsMatrix[x].append([])
			mapPropsMatrix[x][y] = payload.tiles[x][y][1]
			mapMovementMatrix[x].append([])
			mapMovementMatrix[x][y] = payload.tiles[x][y][2]
	
	groundTileMap.setSize(mapWidth, mapHeight)
	propsTileMap.setSize(mapWidth, mapHeight)
	movementTileMap.setSize(mapWidth, mapHeight)
	groundTileMap.setCells(mapGroundMatrix)
	propsTileMap.setCells(mapPropsMatrix)
	movementTileMap.setCells(mapMovementMatrix)
	
	for z in range(payload.playerStartRules.size()):
		if payload.playerStartRules[z].get("armies"):
			instantiate_player_armies(z, payload.playerStartRules[z].armies)

func instantiate_player_armies(player_nr, player_armies):
	playersArmies.append([])
	playersArmies[player_nr] = []
	army_instances.append([])
	army_instances[player_nr] = []
	for h in range(player_armies.size()):
		playersArmies[player_nr].append([])
		playersArmies[player_nr][h] = player_armies[h]
		army_instances[player_nr].append(armyNode.duplicate())
		var pos = Vector2(player_armies[h].x, player_armies[h].y)
		army_instances[player_nr][h].my_coords = pos
		army_instances[player_nr][h].position = propsTileMap.map_to_world(pos)
		army_instances[player_nr][h].position.y += 36
		propsTileMap.add_child(army_instances[player_nr][h])
		if player_armies[h].get("cameraStartPosition") && player_armies[h].cameraStartPosition == true:
			camera.followNode(army_instances[player_nr][h].position)
		if player_armies[h].get("selected") && player_armies[h].selected == true:
			selected_army.x = player_nr
			selected_army.y = h

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mouse_pos = get_global_mouse_position()
	var tile = groundTileMap.world_to_map(mouse_pos)
	var move_tile = movementTileMap.get_cell(tile.x, tile.y)
	if tile.x == playersArmies[selected_army.x][selected_army.y].x && tile.y == playersArmies[selected_army.x][selected_army.y].y:
		Input.set_default_cursor_shape(Input.CURSOR_HELP)
	elif move_tile == 0:
		#Input.set_default_cursor_shape(Input.CURSOR_MOVE)
		Input.set_custom_mouse_cursor(m_pointer_go)
	elif move_tile == 1:
		#Input.set_default_cursor_shape(Input.CURSOR_FORBIDDEN)
		Input.set_custom_mouse_cursor(m_pointer_blocked)
	elif move_tile == 2:
		#Input.set_default_cursor_shape(Input.CURSOR_FORBIDDEN)
		Input.set_custom_mouse_cursor(m_pointer_blocked)
	elif move_tile == 3:
		Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	# TODO: Finish implementing the mouse cursor changes.
	var text = "tile: %s, pos: %s" % [tile, mouse_pos]
	info.set_text(text)
	
func _input(event):
	if camera.tween.is_active():
		return
		
	var p_a_s_x = army_instances[selected_army.x][selected_army.y].my_coords.x
	var p_a_s_y = army_instances[selected_army.x][selected_army.y].my_coords.y
		
	if Input.is_action_just_released("army_left"):
		if isTileAccessible(p_a_s_x - 1, p_a_s_y + 1):
#			playersArmies[selected_army.x][selected_army.y].x -= 1
#			playersArmies[selected_army.x][selected_army.y].y += 1
#			command_given = true
			army_instances[selected_army.x][selected_army.y].calculateFastestPath(p_a_s_x - 1, p_a_s_y + 1)
	if Input.is_action_just_released("army_right"):
		if isTileAccessible(p_a_s_x + 1, p_a_s_y - 1):
#			playersArmies[selected_army.x][selected_army.y].x += 1
#			playersArmies[selected_army.x][selected_army.y].y -= 1
#			command_given = true
			army_instances[selected_army.x][selected_army.y].calculateFastestPath(p_a_s_x + 1, p_a_s_y - 1)
	if Input.is_action_just_released("army_up"):
		if isTileAccessible(p_a_s_x - 1, p_a_s_y - 1):
#			playersArmies[selected_army.x][selected_army.y].x -= 1
#			playersArmies[selected_army.x][selected_army.y].y -= 1
#			command_given = true
			army_instances[selected_army.x][selected_army.y].calculateFastestPath(p_a_s_x - 1, p_a_s_y - 1)
	if Input.is_action_just_released("army_down"):
		if isTileAccessible(p_a_s_x + 1, p_a_s_y + 1):
#			playersArmies[selected_army.x][selected_army.y].x += 1
#			playersArmies[selected_army.x][selected_army.y].y += 1
#			command_given = true
			army_instances[selected_army.x][selected_army.y].calculateFastestPath(p_a_s_x + 1, p_a_s_y + 1)
	if Input.is_action_just_released("army_up_left"):
		if isTileAccessible(p_a_s_x - 1, p_a_s_y):
#			playersArmies[selected_army.x][selected_army.y].x -= 1
#			command_given = true
			army_instances[selected_army.x][selected_army.y].calculateFastestPath(p_a_s_x - 1, p_a_s_y)
	if Input.is_action_just_released("army_up_right"):
		if isTileAccessible(p_a_s_x, p_a_s_y - 1):
#			playersArmies[selected_army.x][selected_army.y].y -= 1
#			command_given = true
			army_instances[selected_army.x][selected_army.y].calculateFastestPath(p_a_s_x, p_a_s_y - 1)
	if Input.is_action_just_released("army_down_left"):
		if isTileAccessible(p_a_s_x, p_a_s_y + 1):
#			playersArmies[selected_army.x][selected_army.y].y += 1
#			command_given = true
			army_instances[selected_army.x][selected_army.y].calculateFastestPath(p_a_s_x, p_a_s_y + 1)
	if Input.is_action_just_released("army_down_right"):
		if isTileAccessible(p_a_s_x + 1, p_a_s_y):
#			playersArmies[selected_army.x][selected_army.y].x += 1
#			command_given = true
			army_instances[selected_army.x][selected_army.y].calculateFastestPath(p_a_s_x + 1, p_a_s_y)
	if Input.is_action_just_released("select_tile"):
		var tile = groundTileMap.world_to_map(get_global_mouse_position())
		if (tile.x != p_a_s_x || tile.y != p_a_s_y) && isTileAccessible(tile.x, tile.y):
			if army_instances[selected_army.x][selected_army.y].selected_coords == tile:
				command_given = true
			else:
				army_instances[selected_army.x][selected_army.y].calculateFastestPath(tile.x, tile.y)

func isTileAccessible(x, y):
	if x < 0 || x >= mapWidth || y < 0 || y >= mapHeight:
		return false
	elif army_instances[selected_army.x][selected_army.y].travel_type == 0:
		if movementTileMap.get_cell(x,y) == 0 || movementTileMap.get_cell(x,y) == 3:
			return true
		else:
			return false
	elif army_instances[selected_army.x][selected_army.y].travel_type == 1:
		if movementTileMap.get_cell(x,y) == 1 || movementTileMap.get_cell(x,y) == 3:
			return true
		else:
			return false
	else:
		return false
	
