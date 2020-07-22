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
				},
				{
					"x": 1,
					"y": 2,
					"cameraStartPosition": false,
					"selected": false,
					"heroId": 1
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
var landMassMatrix = []
var groundTileMap
var propsTileMap
var movementTileMap
var adventureMap
var current_mass_type = -1
# Object References
var save_name_input
var save_map_button
# Startup Flags
var showEditor = false

func _ready():
	groundTileMap = get_node("../TM-Ground")
	propsTileMap = get_node("../TM-Props")
	movementTileMap = get_node("../TM-Movement")
	save_name_input = get_node("saveMapName")
	save_map_button = get_node("saveMapButton")
	if showEditor == true:
		save_name_input.visible = true
		save_map_button.visible = true

func _on_saveMapButton_pressed():
	var saveName = "test1"
	if save_name_input.text != "":
		saveName = save_name_input.text
	var filePath = str("res://Maps/", saveName, ".json")
	
	data.name = saveName
	
	var file
	file = File.new()
	file.open(filePath, File.WRITE)
	file.store_line(to_json(data))
	file.close()

func readMapData():
	movementTileMap.determineCells()
	initPaintedMatrix()
	floodFillLandMasses()
	
	for y in range(data.width):
		data.tiles.append([])
		data.tiles[y] = []
		for x in range(data.height):
			data.tiles[y].append([])
			data.tiles[y][x] = [mapGroundMatrix[y][x], mapPropsMatrix[y][x], mapMovementMatrix[y][x], landMassMatrix[y][x]]

# Temporary function used to save maps made with Godot before starting the game.
func initPaintedMatrix():
	for x in range(data.width):
		mapGroundMatrix.append([])
		mapGroundMatrix[x] = []
		mapPropsMatrix.append([])
		mapPropsMatrix[x] = []
		mapMovementMatrix.append([])
		mapMovementMatrix[x] = []
		landMassMatrix.append([])
		landMassMatrix[x] = []
		for y in range(data.height):
			mapGroundMatrix[x].append([])
			mapGroundMatrix[x][y] = groundTileMap.get_cell(x, y)
			mapPropsMatrix[x].append([])
			mapPropsMatrix[x][y] = propsTileMap.get_cell(x, y)
			mapMovementMatrix[x].append([])
			mapMovementMatrix[x][y] = movementTileMap.get_cell(x, y)
			landMassMatrix[x].append([])
			landMassMatrix[x][y] = -1

# We use a flood fill algorithm to find all the land masses present on the map
# CAUTION! This list also includes sea masses!
func floodFillLandMasses():
	var current_land_mass_nr = 1
	for x in range(data.width):
		for y in range(data.height):
			if landMassMatrix[x][y] == -1:
				if mapMovementMatrix[x][y] == 2:
					landMassMatrix[x][y] = 0
				else:
					if mapGroundMatrix[x][y] == 1:
						current_mass_type = 1
					else:
						current_mass_type = 0
					floodFillPortion(x, y, current_land_mass_nr)
					current_land_mass_nr += 1

func floodFillPortion(x, y, c_l_m_nr):
	if x >= 0 && x < data.width && y >= 0 && y < data.height && landMassMatrix[x][y] == -1:
		if mapMovementMatrix[x][y] == 2:
			landMassMatrix[x][y] = 0
		elif (mapGroundMatrix[x][y] == 1 && current_mass_type == 1) || (mapGroundMatrix[x][y] != 1 && current_mass_type == 0):
			landMassMatrix[x][y] = c_l_m_nr
			floodFillPortion(x + 1, y, c_l_m_nr)
			floodFillPortion(x + 1, y + 1, c_l_m_nr)
			floodFillPortion(x, y + 1, c_l_m_nr)
			floodFillPortion(x - 1, y, c_l_m_nr)
			floodFillPortion(x - 1, y + 1, c_l_m_nr)
			floodFillPortion(x - 1, y - 1, c_l_m_nr)
			floodFillPortion(x, y - 1, c_l_m_nr)
			floodFillPortion(x + 1, y - 1, c_l_m_nr)
