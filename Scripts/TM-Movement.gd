extends TileMap

var width
var height
var groundTileMap
var propsTileMap
var adventure_map
var groundWalkProp = "res://Data/groundWalkableProperties.json"
var ground_travel_properties
var propsBlockedTiles = "res://Data/propsBlockedTiles.json"
var props_blocked_tiles
var tile_move_expense = []
var landMassesMatrix = []

func _ready():
	groundTileMap = get_node("../TM-Ground")
	propsTileMap = get_node("../TM-Props")
	adventure_map = get_parent()
	ground_travel_properties = adventure_map.loadFilePayload(groundWalkProp)
	props_blocked_tiles = adventure_map.loadFilePayload(propsBlockedTiles)

func setSize(x, y):
	width = x
	height = y

func setCells(data):
	for cell in data:
		landMassesMatrix.append([cell[0], cell[1], cell[5]])
		tile_move_expense.append([cell[0], cell[1], ground_travel_properties[groundTileMap.get_cell(cell[0],cell[1])][1]])
		set_cell(cell[0], cell[1], cell[4])

func getLandMassOfCell(x, y):
	for cell in landMassesMatrix:
		if cell[0] == x && cell[1] == y:
			return cell[2]
	return -1

func getMoveExpenseOfCell(x, y):
	for cell in tile_move_expense:
		if cell[0] == x && cell[1] == y:
			return cell[2]
	return -1

func determineCells():
	var temp_cell = 0
	var temp_prop_blocked_tiles = []
	for x in range(-width, width):
		for y in range(-height, height):
			if groundTileMap.get_cell(x,y) > -1:
				temp_cell = propsTileMap.get_cell(x,y)
				if temp_cell >= 0:
					temp_cell = String(temp_cell)
					if temp_cell in props_blocked_tiles:
						temp_prop_blocked_tiles = props_blocked_tiles[temp_cell]
						for blocked_tile in temp_prop_blocked_tiles:
							set_cell(x + blocked_tile[0], y + blocked_tile[1], 2)
					else:
						set_cell(x, y, 3)
				elif get_cell(x, y) < 0:
					set_cell(x, y, ground_travel_properties[groundTileMap.get_cell(x,y)][0])
