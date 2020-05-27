extends Node2D

# Declare member variables here. Examples:
var mapPath = "res://Maps/test4.json"
var interactablesPath = "res://Data/mapInteractables.json"
var mapGroundMatrix = []
var mapPropsMatrix = []
var mapInteractableMatrix = []
var info
var mapWidth = 0
var mapHeight = 0
var groundTileMap
var propsTileMap
var interactableTileMap
var camera
var armyNode

var playersArmies = []
var army_instances = []

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
					"x": 2,
					"y": 2,
					"cameraStartPosition": true,
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
	interactableTileMap = get_node("TM-Interactable")
	info = get_node("UI/info")
	armyNode = get_node("Army")
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
			data.tiles[y][x] = [mapGroundMatrix[y][x], mapPropsMatrix[y][x], mapInteractableMatrix[y][x]]
	
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
	
func loadMapData():
	var file = File.new()
	if not file.file_exists(mapPath):
		return
	file.open(mapPath, File.READ)
	
	var payload = parse_json(file.get_as_text())
	mapWidth = payload.width
	mapHeight = payload.height
	prepCamera()
	
	for y in range(mapHeight):
		mapGroundMatrix.append([])
		mapGroundMatrix[y] = []
		mapPropsMatrix.append([])
		mapPropsMatrix[y] = []
		mapInteractableMatrix.append([])
		mapInteractableMatrix[y] = []
		for x in range(mapWidth):
			mapGroundMatrix[y].append([])
			mapGroundMatrix[y][x] = payload.tiles[y][x][0]
			groundTileMap.set_cell(x, y, mapGroundMatrix[y][x])
			mapPropsMatrix[y].append([])
			mapPropsMatrix[y][x] = payload.tiles[y][x][1]
			propsTileMap.set_cell(x, y, mapPropsMatrix[y][x])
			mapInteractableMatrix[y].append([])
			mapInteractableMatrix[y][x] = payload.tiles[y][x][2]
			interactableTileMap.set_cell(x, y, mapInteractableMatrix[y][x])
			
	for z in range(payload.playerStartRules.size()):
		if payload.playerStartRules[z].get("armies"):
			instantiate_player_armies(z, payload.playerStartRules[z].armies)
	
	file.close()

# Temporary function used to save maps made with Godot before starting the game.
func initPaintedMatrix():
	for y in range(data.width):
		mapGroundMatrix.append([])
		mapGroundMatrix[y] = []
		mapPropsMatrix.append([])
		mapPropsMatrix[y] = []
		mapInteractableMatrix.append([])
		mapInteractableMatrix[y] = []
		for x in range(data.height):
			mapGroundMatrix[y].append([])
			mapGroundMatrix[y][x] = groundTileMap.get_cell(x, y)
			mapPropsMatrix[y].append([])
			mapPropsMatrix[y][x] = propsTileMap.get_cell(x, y)
			mapInteractableMatrix[y].append([])
			mapInteractableMatrix[y][x] = interactableTileMap.get_cell(x, y)
			
func instantiate_player_armies(player_nr, player_data):
	playersArmies.append([])
	playersArmies[player_nr] = []
	army_instances.append([])
	army_instances[player_nr] = []
	for h in range(player_data.size()):
		playersArmies[player_nr].append([])
		playersArmies[player_nr][h] = player_data[h]
		army_instances[player_nr].append(armyNode.duplicate())
		var pos = Vector2(player_data[h].x, player_data[h].y)
		army_instances[player_nr][0].position = interactableTileMap.map_to_world(pos)
#		army_instances[player_nr][0].position.x += 72
#		army_instances[player_nr][0].position.y += 36
		print(interactableTileMap.map_to_world(pos))
		add_child(army_instances[player_nr][0])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mouse_pos = get_global_mouse_position()
	var tile = groundTileMap.world_to_map(mouse_pos)
	var text = "tile: %s, mouse_pos: %s" % [tile, mouse_pos]
	info.set_text(text)
