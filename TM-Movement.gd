extends TileMap

var width
var height
var groundTileMap
var propsTileMap

func _ready():
	groundTileMap = get_node("../TM-Ground")
	propsTileMap = get_node("../TM-Props")

func setSize(x, y):
	width = x
	height = y

func setCells(data):
	for x in range(height):
		for y in range(width):
			set_cell(x, y, data[x][y])

func determineCells():
	for x in range(height):
		for y in range(width):
			if(groundTileMap.get_cell(x,y) == 1):
				set_cell(x,y, 1)
