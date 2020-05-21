extends Node2D

# Declare member variables here. Examples:
var mapPath = "res://Maps/test3.json"
var mapGroundMatrix = []
var mapPropsMatrix = []
var info
var mapWidth = 0
var mapHeight = 0
var groundTileMap
var propsTileMap
var camera

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
			"startingAlliance": 0
		},
		{
			"canBeHuman": false,
			"forcedFaction": 2,
			"forcedCaptain": 0,
			"forcedStartBonus": 1,
			"startingAlliance": 0
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
	info = get_node("UI/info")
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
			data.tiles[y][x] = [mapGroundMatrix[y][x], mapPropsMatrix[y][x], -1]
	
	var file
	file = File.new()
	file.open(filePath, File.WRITE)
	file.store_line(to_json(data))
	file.close()
	
func loadMapData():
	var file = File.new()
	if not file.file_exists(mapPath):
		return
	file.open(mapPath, File.READ)
	
	var payload = parse_json(file.get_as_text())
	mapWidth = payload.width
	mapHeight = payload.height
	
	for y in range(mapHeight):
		mapGroundMatrix.append([])
		mapGroundMatrix[y] = []
		mapPropsMatrix.append([])
		mapPropsMatrix[y] = []
		for x in range(mapWidth):
			mapGroundMatrix[y].append([])
			mapGroundMatrix[y][x] = payload.tiles[y][x][0]
			groundTileMap.set_cell(x, y, mapGroundMatrix[y][x])
			mapPropsMatrix[y].append([])
			mapPropsMatrix[y][x] = payload.tiles[y][x][1]
			propsTileMap.set_cell(x, y, mapPropsMatrix[y][x])
	
	file.close()

func initPaintedMatrix():
	for y in range(data.width):
		mapGroundMatrix.append([])
		mapGroundMatrix[y] = []
		mapPropsMatrix.append([])
		mapPropsMatrix[y] = []
		for x in range(data.height):
			mapGroundMatrix[y].append([])
			mapGroundMatrix[y][x] = groundTileMap.get_cell(x, y)
			mapPropsMatrix[y].append([])
			mapPropsMatrix[y][x] = propsTileMap.get_cell(x, y)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mouse_pos = get_global_mouse_position()
	var tile = groundTileMap.world_to_map(mouse_pos)
	var text = "tile: %s" % [tile]
	info.set_text(text)
