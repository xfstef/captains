extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var mapPath = "res://Maps/test1.json"

var mapGroundMatrix = []
var mapPropsMatrix = []
var mapWidth = 0
var mapHeight = 0
var groundTileMap
var propsTileMap

# Called when the node enters the scene tree for the first time.
func _ready():
	groundTileMap = get_node("TM-Ground")
	propsTileMap = get_node("TM-Props")
	loadMapData()
	
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
