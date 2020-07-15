extends Node2D

# Paths
var mapPath = "res://Maps/test4.json"
var interactablesPath = "res://Data/mapInteractables.json"
var directionIndexesPath = "res://Data/directionIndexes.json"
# World Object References
var camera
var armyNode
var groundTileMap
var propsTileMap
var movementTileMap
var mouseCtrl
var info
var moveTracker
# Instanced Objects
var playersArmies = []
var army_instances = []
var movement_trackers = []
var direction_indexes = {}
# Other
var mapGroundMatrix = []
var mapPropsMatrix = []
var mapMovementMatrix = []
var landMassesMatrix = []
var mapWidth = 0
var mapHeight = 0
var selected_army
var command_given = false

# Called when the node enters the scene tree for the first time.
func _ready():
	camera = get_node("Camera2D")
	groundTileMap = get_node("TM-Ground")
	propsTileMap = get_node("TM-Props")
	movementTileMap = get_node("TM-Movement")
	mouseCtrl = get_node("MouseCtrl")
	info = get_node("UI/info")
	armyNode = get_node("Army")
	moveTracker = get_node("MoveTracker")
	loadMapData()
	direction_indexes = loadFilePayload(directionIndexesPath)

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
	mouseCtrl.mapWidth = mapWidth
	mouseCtrl.mapHeight = mapHeight
	prepCamera()
	
	for x in range(mapHeight):
		mapGroundMatrix.append([])
		mapGroundMatrix[x] = []
		mapPropsMatrix.append([])
		mapPropsMatrix[x] = []
		mapMovementMatrix.append([])
		mapMovementMatrix[x] = []
		landMassesMatrix.append([])
		landMassesMatrix[x] = []
		for y in range(mapWidth):
			mapGroundMatrix[x].append([])
			mapGroundMatrix[x][y] = payload.tiles[x][y][0]
			mapPropsMatrix[x].append([])
			mapPropsMatrix[x][y] = payload.tiles[x][y][1]
			mapMovementMatrix[x].append([])
			mapMovementMatrix[x][y] = payload.tiles[x][y][2]
			landMassesMatrix[x].append([])
			landMassesMatrix[x][y] = payload.tiles[x][y][3]
	
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
		army_instances[player_nr][h].current_land_mass = landMassesMatrix[pos.x][pos.y]
		army_instances[player_nr][h].my_id = h
		propsTileMap.add_child(army_instances[player_nr][h])
		if player_armies[h].get("cameraStartPosition") && player_armies[h].cameraStartPosition == true:
			camera.followNode(army_instances[player_nr][h].position)
		if player_armies[h].get("selected") && player_armies[h].selected == true:
			selected_army = {player_id = player_nr, army_id = h}

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):

func _input(event):
	if camera.tween.is_active():
		return
		
	var p_a_s_x = army_instances[selected_army.player_id][selected_army.army_id].my_coords.x
	var p_a_s_y = army_instances[selected_army.player_id][selected_army.army_id].my_coords.y
	var army_travel_type = army_instances[selected_army.player_id][selected_army.army_id].travel_type
	var army_land_mass = army_instances[selected_army.player_id][selected_army.army_id].current_land_mass
	
	if Input.is_action_just_released("army_left"):
		if isTileAccessible(p_a_s_x - 1, p_a_s_y + 1, army_travel_type, army_land_mass):
			army_instances[selected_army.player_id][selected_army.army_id].moveTo(propsTileMap.map_to_world(Vector2(p_a_s_x - 1, p_a_s_y + 1)))
	if Input.is_action_just_released("army_right"):
		if isTileAccessible(p_a_s_x + 1, p_a_s_y - 1, army_travel_type, army_land_mass):
			army_instances[selected_army.player_id][selected_army.army_id].moveTo(propsTileMap.map_to_world(Vector2(p_a_s_x + 1, p_a_s_y - 1)))
	if Input.is_action_just_released("army_up"):
		if isTileAccessible(p_a_s_x - 1, p_a_s_y - 1, army_travel_type, army_land_mass):
			army_instances[selected_army.player_id][selected_army.army_id].moveTo(propsTileMap.map_to_world(Vector2(p_a_s_x - 1, p_a_s_y - 1)))
	if Input.is_action_just_released("army_down"):
		if isTileAccessible(p_a_s_x + 1, p_a_s_y + 1, army_travel_type, army_land_mass):
			army_instances[selected_army.player_id][selected_army.army_id].moveTo(propsTileMap.map_to_world(Vector2(p_a_s_x + 1, p_a_s_y + 1)))
	if Input.is_action_just_released("army_up_left"):
		if isTileAccessible(p_a_s_x - 1, p_a_s_y, army_travel_type, army_land_mass):
			army_instances[selected_army.player_id][selected_army.army_id].moveTo(propsTileMap.map_to_world(Vector2(p_a_s_x - 1, p_a_s_y)))
	if Input.is_action_just_released("army_up_right"):
		if isTileAccessible(p_a_s_x, p_a_s_y - 1, army_travel_type, army_land_mass):
			army_instances[selected_army.player_id][selected_army.army_id].moveTo(propsTileMap.map_to_world(Vector2(p_a_s_x, p_a_s_y - 1)))
	if Input.is_action_just_released("army_down_left"):
		if isTileAccessible(p_a_s_x, p_a_s_y + 1, army_travel_type, army_land_mass):
			army_instances[selected_army.player_id][selected_army.army_id].moveTo(propsTileMap.map_to_world(Vector2(p_a_s_x, p_a_s_y + 1)))
	if Input.is_action_just_released("army_down_right"):
		if isTileAccessible(p_a_s_x + 1, p_a_s_y, army_travel_type, army_land_mass):
			army_instances[selected_army.player_id][selected_army.army_id].moveTo(propsTileMap.map_to_world(Vector2(p_a_s_x + 1, p_a_s_y)))
	if Input.is_action_just_released("select_tile"):
		var tile = groundTileMap.world_to_map(get_global_mouse_position())
		if (tile.x != p_a_s_x || tile.y != p_a_s_y) && isTileAccessible(tile.x, tile.y, army_travel_type, army_land_mass):
			if army_instances[selected_army.player_id][selected_army.army_id].selected_coords == tile:
				army_instances[selected_army.player_id][selected_army.army_id].executeMoveCommand = true
			else:
				for h in range(movement_trackers.size()):
					movement_trackers[h].visible = false
				army_instances[selected_army.player_id][selected_army.army_id].calculateFastestPath(tile.x, tile.y)

# TODO: Improve this function so that it takes into consideration the army travel type and land masses and portals
func isTileAccessible(x, y, travel_type, land_mass):
	if x < 0 || x >= mapWidth || y < 0 || y >= mapHeight:
		return false
	elif land_mass != landMassesMatrix[x][y]:
		return false
	elif travel_type == 0:
		if movementTileMap.get_cell(x,y) == 0 || movementTileMap.get_cell(x,y) == 3:
			return true
		else:
			return false
	elif travel_type == 1:
		if movementTileMap.get_cell(x,y) == 1 || movementTileMap.get_cell(x,y) == 3:
			return true
		else:
			return false
	else:
		return false

func getNodeNeighbours(node, army_travel_type, land_mass):
	var valid_neighbours = []
	var new_x
	var new_y
	
	for x in range(-1, 2):
		for y in range(-1, 2):
			if !(x == 0 && y == 0):
				new_x = node.x + x
				new_y = node.y + y
				if isTileAccessible(new_x, new_y, army_travel_type, land_mass):
					valid_neighbours.append(Vector2(new_x, new_y))
	
	return valid_neighbours

func drawPath(army_id):
	var nodes = army_instances[selected_army.player_id][army_id].fastest_path
	nodes.push_front({x = army_instances[selected_army.player_id][army_id].my_coords.x, y = army_instances[selected_army.player_id][army_id].my_coords.y})
	for x in range(1, nodes.size()):
		if movement_trackers.size() < x:
			movement_trackers.append(moveTracker.duplicate())
			propsTileMap.add_child(movement_trackers[x - 1])
		movement_trackers[x - 1].position = propsTileMap.map_to_world(Vector2(nodes[x].x, nodes[x].y))
		movement_trackers[x - 1].position.y += 36
		if x + 1 < nodes.size():
			movement_trackers[x - 1].frame = establishDirection(nodes[x - 1], nodes[x], nodes[x + 1])
		else:
			movement_trackers[x - 1].frame = 12
		movement_trackers[x - 1].visible = true

func establishDirection(n_1, n_2, n_3):
	var x_d_1 = String(n_1.x - n_2.x)
	var y_d_1 = String(n_1.y - n_2.y)
	var x_d_2 = String(n_3.x - n_2.x)
	var y_d_2 = String(n_3.y - n_2.y)
	
	return direction_indexes.get(x_d_1).get(y_d_1).get(x_d_2).get(y_d_2)
