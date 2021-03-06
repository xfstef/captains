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
					"heroId": 0,
					"portraitId": 0,
					"units": [
							{"unitId": 0, "amount": 1, "captainId": -1},
							{"unitId": 1, "amount": 5, "captainId": 0}
					],
					"cache": { 
						"lumber": 5, 
						"stone": 5, 
						"steam": 2, 
						"iron": 2, 
						"gems": 1, 
						"shards": 3, 
						"gold": 2000
					},
					"general_skills": {
						"charisma": 2,
						"barter": 0
					}
				}
			],
			"castles": [{"cameraStartPosition":false,"townId":0,"selected":false,"x":3,"y":5}]
		},
		{
			"canBeHuman": false,
			"forcedFaction": 2,
			"forcedCaptain": 0,
			"forcedStartBonus": 1,
			"startingAlliance": 0,
			"color": 1,
			"castles": [{"cameraStartPosition":false,"townId":1,"selected":false,"x":1,"y":1}]
		}
	],
	"neutralStartRules":[
		
	],
	"winConditions": [0],
	"lossConditions": [0, 1],
	"width": 16,
	"height": 16,
	"tiles": [],
	"npcs": [],
	"specialEvents": {}
}
var range_x = data.width - 1
var range_y = data.height - 1
#var mapGroundMatrix = []
#var mapPropsMatrix = []
#var mapMovementMatrix = []
#var landMassMatrix = []
var cellData = []
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
	data.tiles = cellData
#	for y in range(data.width):
#		data.tiles.append([])
#		data.tiles[y] = []
#		for x in range(data.height):
#			data.tiles[y].append([])
#			data.tiles[y][x] = [mapGroundMatrix[y][x], mapPropsMatrix[y][x], mapMovementMatrix[y][x], landMassMatrix[y][x]]
	getUnits()

func getUnits():
	for child in propsTileMap.get_children():
		data.npcs.append({x = child.my_coords.x, y = child.my_coords.y, name = child.unit_name})

# Temporary function used to save maps made with Godot before starting the game.
func initPaintedMatrix():
	for x in range(-range_x, range_x + 1):
		for y in range(-range_y, range_y + 1):
			if groundTileMap.get_cell(x,y) > -1:
				cellData.append(
					[x,
					 y,
					 groundTileMap.get_cell(x,y),
					 propsTileMap.get_cell(x,y),
					 movementTileMap.get_cell(x,y),
					 -1])
	 
#	for x in range(data.width):
#		mapGroundMatrix.append([])
#		mapGroundMatrix[x] = []
#		mapPropsMatrix.append([])
#		mapPropsMatrix[x] = []
#		mapMovementMatrix.append([])
#		mapMovementMatrix[x] = []
#		landMassMatrix.append([])
#		landMassMatrix[x] = []
#		for y in range(data.height):
#			mapGroundMatrix[x].append([])
#			mapGroundMatrix[x][y] = groundTileMap.get_cell(x, y)
#			mapPropsMatrix[x].append([])
#			mapPropsMatrix[x][y] = propsTileMap.get_cell(x, y)
#			mapMovementMatrix[x].append([])
#			mapMovementMatrix[x][y] = movementTileMap.get_cell(x, y)
#			landMassMatrix[x].append([])
#			landMassMatrix[x][y] = -1

# We use a flood fill algorithm to find all the land masses present on the map
# CAUTION! This list also includes sea masses!
func floodFillLandMasses():
	var current_land_mass_nr = 1
	var cell = []
	for x in range(cellData.size()):
		cell = cellData[x]
		if cell[5] == -1:
			if cell[4] == 2:
				cell[5] = 0
			else:
				if cell[2] == 1:
					current_mass_type = 1
				else:
					current_mass_type = 0
				floodFillPortion(cell, current_land_mass_nr)
				current_land_mass_nr += 1
#	for x in range(data.width):
#		for y in range(data.height):
#			if landMassMatrix[x][y] == -1:
#				if mapMovementMatrix[x][y] == 2:
#					landMassMatrix[x][y] = 0
#				else:
#					if mapGroundMatrix[x][y] == 1:
#						current_mass_type = 1
#					else:
#						current_mass_type = 0
#					floodFillPortion(x, y, current_land_mass_nr)
#					current_land_mass_nr += 1

func floodFillPortion(cell, c_l_m_nr):
	if cell != null && cell[5] == -1:
		if cell[4] == 2:
			cell[5] = 0
		elif (cell[4] == 1 && current_mass_type == 1) || (cell[4] != 1 && current_mass_type == 0):
			cell[5] = c_l_m_nr
			if cell[0] + 1 <= range_x:
				floodFillPortion(findCell(cell[0] + 1, cell[1]), c_l_m_nr)
			if cell[0] + 1 <= range_x && cell[1] + 1 <= range_y:
				floodFillPortion(findCell(cell[0] + 1, cell[1] + 1), c_l_m_nr)
			if cell[1] + 1 <= range_y:
				floodFillPortion(findCell(cell[0], cell[1] + 1), c_l_m_nr)
			if cell[0] - 1 >= -range_x:
				 floodFillPortion(findCell(cell[0] - 1, cell[1]), c_l_m_nr)
			if cell[0] - 1 >= -range_x && cell[1] + 1 <= range_y:
				floodFillPortion(findCell(cell[0] - 1, cell[1] + 1), c_l_m_nr)
			if cell[0] - 1 >= -range_x && cell[1] - 1 >= -range_y:
				floodFillPortion(findCell(cell[0] - 1, cell[1] - 1), c_l_m_nr)
			if cell[1] - 1 >= -range_y:
				floodFillPortion(findCell(cell[0], cell[1] - 1), c_l_m_nr)
			if cell[0] + 1 <= range_x && cell[1] - 1 >= -range_y:
				floodFillPortion(findCell(cell[0] + 1, cell[1] - 1), c_l_m_nr)
			
#	if x >= 0 && x < data.width && y >= 0 && y < data.height && landMassMatrix[x][y] == -1:
#		if mapMovementMatrix[x][y] == 2:
#			landMassMatrix[x][y] = 0
#		elif (mapGroundMatrix[x][y] == 1 && current_mass_type == 1) || (mapGroundMatrix[x][y] != 1 && current_mass_type == 0):
#			landMassMatrix[x][y] = c_l_m_nr
#			floodFillPortion(x + 1, y, c_l_m_nr)
#			floodFillPortion(x + 1, y + 1, c_l_m_nr)
#			floodFillPortion(x, y + 1, c_l_m_nr)
#			floodFillPortion(x - 1, y, c_l_m_nr)
#			floodFillPortion(x - 1, y + 1, c_l_m_nr)
#			floodFillPortion(x - 1, y - 1, c_l_m_nr)
#			floodFillPortion(x, y - 1, c_l_m_nr)
#			floodFillPortion(x + 1, y - 1, c_l_m_nr)

func findCell(x, y):
	var cell = []
	for z in range(cellData.size()):
		cell = cellData[z]
		if cell[0] == x && cell[1] == y:
			return cell
