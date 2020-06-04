extends Node2D

# Declare member variables here. Examples:
var mapPath = "res://Maps/test4.json"
var interactablesPath = "res://Data/mapInteractables.json"
var groundWalkProp = "res://Data/groundWalkableProperties.json"
var mapGroundMatrix = []
var mapPropsMatrix = []
var mapDoodadsMatrix = []
var info
var mapWidth = 0
var mapHeight = 0
var groundTileMap
var propsTileMap
var doodadsTileMap
var camera
var armyNode
var tile_travel_properties
var tile_travel_expenses_matrix = []

var playersArmies = []
var army_instances = []
var selected_army = Vector2()
var command_given = false

var data = {
	"name": "",
	"description": "...",
	"numberOfPlayers": 2,
	"playerStartRules": [
		{
			"canBeHuman": true,
			"forcedFaction": 0,
			"forcedCaptain": 0,
			"forcedStartBonus": 0,
			"startingAlliance": 0,
			"color": 0,
			"armies": [
				{
					"x": 6,
					"y": 7,
					"cameraStartPosition": true,
					"selected": true,
					"heroId": 0
				}
			],
			"castles": []
		},
		{
			"canBeHuman": false,
			"forcedFaction": 2,
			"forcedCaptain": 0,
			"forcedStartBonus": 1,
			"startingAlliance": 0,
			"color": 1
		}
	],
	"winConditions": [0],
	"lossConditions": [0, 1],
	"width": 16,
	"height": 16,
	"tiles": []
}

# Called when the node enters the scene tree for the first time.
func _ready():
	camera = get_node("Camera2D")
	groundTileMap = get_node("TM-Ground")
	propsTileMap = get_node("TM-Props")
	doodadsTileMap = get_node("TM-Doodads")
	info = get_node("UI/info")
	armyNode = get_node("Army")
	tile_travel_properties = loadFilePayload(groundWalkProp)
	print(tile_travel_properties)
	loadMapData()
	#initPaintedMatrix()
	
func _on_saveMapButton_pressed():
	var saveNameInput = get_node("UI/saveMapName")
	var saveName = "test1"
	if saveNameInput.text != "":
		saveName = saveNameInput.text
	var filePath = str("res://Maps/", saveName, ".json")
	
	data.name = saveName
	
	for y in range(data.width):
		data.tiles.append([])
		data.tiles[y] = []
		for x in range(data.height):
			data.tiles[y].append([])
			data.tiles[y][x] = [mapGroundMatrix[y][x], mapDoodadsMatrix[y][x], mapPropsMatrix[y][x]]
	
	var file
	file = File.new()
	file.open(filePath, File.WRITE)
	file.store_line(to_json(data))
	file.close()
	
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
	
	for y in range(mapHeight):
		mapGroundMatrix.append([])
		mapGroundMatrix[y] = []
		mapPropsMatrix.append([])
		mapPropsMatrix[y] = []
		mapDoodadsMatrix.append([])
		mapDoodadsMatrix[y] = []
		for x in range(mapWidth):
			mapGroundMatrix[y].append([])
			mapGroundMatrix[y][x] = payload.tiles[y][x][0]
			groundTileMap.set_cell(x, y, mapGroundMatrix[y][x])
			mapDoodadsMatrix[y].append([])
			mapDoodadsMatrix[y][x] = payload.tiles[y][x][1]
			doodadsTileMap.set_cell(x, y, mapDoodadsMatrix[y][x])
			mapPropsMatrix[y].append([])
			mapPropsMatrix[y][x] = payload.tiles[y][x][2]
			propsTileMap.set_cell(x, y, mapPropsMatrix[y][x])
			
	for z in range(payload.playerStartRules.size()):
		if payload.playerStartRules[z].get("armies"):
			instantiate_player_armies(z, payload.playerStartRules[z].armies)

# Temporary function used to save maps made with Godot before starting the game.
func initPaintedMatrix():
	for y in range(data.width):
		mapGroundMatrix.append([])
		mapGroundMatrix[y] = []
		mapPropsMatrix.append([])
		mapPropsMatrix[y] = []
		mapDoodadsMatrix.append([])
		mapDoodadsMatrix[y] = []
		tile_travel_expenses_matrix.append([])
		tile_travel_expenses_matrix[y] = []
		for x in range(data.height):
			mapGroundMatrix[y].append([])
			mapGroundMatrix[y][x] = groundTileMap.get_cell(x, y)
			mapDoodadsMatrix[y].append([])
			mapDoodadsMatrix[y][x] = doodadsTileMap.get_cell(x, y)
			mapPropsMatrix[y].append([])
			mapPropsMatrix[y][x] = propsTileMap.get_cell(x, y)
			tile_travel_expenses_matrix[y].append([])
			tile_travel_expenses_matrix[y][x] = []
			tile_travel_expenses_matrix[y][x][0] = tile_travel_properties[mapGroundMatrix[y][x]]
			
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
	var text = "tile: %s, pos: %s" % [tile, mouse_pos]
	info.set_text(text)
	
func _input(event):
	if camera.tween.is_active():
		return
		
	if Input.is_action_just_released("army_left"):
		if isTileAccessible(playersArmies[selected_army.x][selected_army.y].x - 1, playersArmies[selected_army.x][selected_army.y].y + 1):
			playersArmies[selected_army.x][selected_army.y].x -= 1
			playersArmies[selected_army.x][selected_army.y].y += 1
			command_given = true
	if Input.is_action_just_released("army_right"):
		if isTileAccessible(playersArmies[selected_army.x][selected_army.y].x + 1, playersArmies[selected_army.x][selected_army.y].y - 1):
			playersArmies[selected_army.x][selected_army.y].x += 1
			playersArmies[selected_army.x][selected_army.y].y -= 1
			command_given = true
	if Input.is_action_just_released("army_up"):
		if isTileAccessible(playersArmies[selected_army.x][selected_army.y].x - 1, playersArmies[selected_army.x][selected_army.y].y - 1):
			playersArmies[selected_army.x][selected_army.y].x -= 1
			playersArmies[selected_army.x][selected_army.y].y -= 1
			command_given = true
	if Input.is_action_just_released("army_down"):
		if isTileAccessible(playersArmies[selected_army.x][selected_army.y].x + 1, playersArmies[selected_army.x][selected_army.y].y + 1):
			playersArmies[selected_army.x][selected_army.y].x += 1
			playersArmies[selected_army.x][selected_army.y].y += 1
			command_given = true
	if Input.is_action_just_released("army_up_left"):
		if isTileAccessible(playersArmies[selected_army.x][selected_army.y].x - 1, playersArmies[selected_army.x][selected_army.y].y):
			playersArmies[selected_army.x][selected_army.y].x -= 1
			command_given = true
	if Input.is_action_just_released("army_up_right"):
		if isTileAccessible(playersArmies[selected_army.x][selected_army.y].x, playersArmies[selected_army.x][selected_army.y].y - 1):
			playersArmies[selected_army.x][selected_army.y].y -= 1
			command_given = true
	if Input.is_action_just_released("army_down_left"):
		if isTileAccessible(playersArmies[selected_army.x][selected_army.y].x, playersArmies[selected_army.x][selected_army.y].y + 1):
			playersArmies[selected_army.x][selected_army.y].y += 1
			command_given = true
	if Input.is_action_just_released("army_down_right"):
		if isTileAccessible(playersArmies[selected_army.x][selected_army.y].x + 1, playersArmies[selected_army.x][selected_army.y].y):
			playersArmies[selected_army.x][selected_army.y].x += 1
			command_given = true
	if Input.is_action_just_released("select_tile"):
		var tile = groundTileMap.world_to_map(get_global_mouse_position())
		#if isTileAccessible(tile.x, tile.y):
		#if mapGroundMatrix[tile.x][tile.y].selected:
			
		
	if command_given:
		executeMoveArmyCommand()
		command_given = false
		

func executeMoveArmyCommand():
	var selected_army_pos
	selected_army_pos = propsTileMap.map_to_world(Vector2(playersArmies[selected_army.x][selected_army.y].x, playersArmies[selected_army.x][selected_army.y].y))
	army_instances[selected_army.x][selected_army.y].moveTo(selected_army_pos)
	camera.followNode(selected_army_pos)
	
func isTileAccessible(x, y):
	if x < 0 || x >= mapWidth || y < 0 || y >= mapHeight:
		return false
	elif army_instances[selected_army].travel_type < tile_travel_expenses_matrix[x][y][0]:
		return false
	else:
		return true
	
