extends CanvasLayer

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
var mapGroundMatrix = []
var mapPropsMatrix = []
var mapMovementMatrix = []
var groundTileMap
var propsTileMap
var movementTileMap

func _ready():
	groundTileMap = get_node("../TM-Ground")
	propsTileMap = get_node("../TM-Props")
	movementTileMap = get_node("../TM-Movement")

func _on_saveMapButton_pressed():
	initPaintedMatrix()
	var saveNameInput = get_node("saveMapName")
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
			data.tiles[y][x] = [mapGroundMatrix[y][x], mapPropsMatrix[y][x], mapMovementMatrix[y][x]]
	
	var file
	file = File.new()
	file.open(filePath, File.WRITE)
	file.store_line(to_json(data))
	file.close()

# Temporary function used to save maps made with Godot before starting the game.
func initPaintedMatrix():
	for x in range(data.width):
		mapGroundMatrix.append([])
		mapGroundMatrix[x] = []
		mapPropsMatrix.append([])
		mapPropsMatrix[x] = []
		mapMovementMatrix.append([])
		mapMovementMatrix[x] = []
		for y in range(data.height):
			mapGroundMatrix[x].append([])
			mapGroundMatrix[x][y] = groundTileMap.get_cell(x, y)
			mapPropsMatrix[x].append([])
			mapPropsMatrix[x][y] = propsTileMap.get_cell(x, y)
			mapMovementMatrix[x].append([])
			mapMovementMatrix[x][y] = movementTileMap.get_cell(x, y)
