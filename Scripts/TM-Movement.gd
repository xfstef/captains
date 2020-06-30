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
	for x in range(height):
		tile_move_expense.append([])
		for y in range(width):
			tile_move_expense[x].append([])
			set_cell(x, y, data[x][y])
			tile_move_expense[x][y] = ground_travel_properties[groundTileMap.get_cell(x,y)][1]

func determineCells():
	var temp_cell = 0
	var temp_prop_blocked_tiles = []
	for x in range(height):
		for y in range(width):
			temp_cell = propsTileMap.get_cell(x,y)
			if temp_cell >= 0:
				if props_blocked_tiles[temp_cell]:
					temp_prop_blocked_tiles = props_blocked_tiles[temp_cell]
					for z in range(temp_prop_blocked_tiles.size()):
						set_cell(x + temp_prop_blocked_tiles[z][0], y + temp_prop_blocked_tiles[z][1], 2)
				else:
					set_cell(x, y, 3)
			elif get_cell(x, y) < 0:
				set_cell(x, y, ground_travel_properties[groundTileMap.get_cell(x,y)][0])
