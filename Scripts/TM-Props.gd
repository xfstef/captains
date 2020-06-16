extends TileMap

var width
var height

func setSize(x, y):
	width = x
	height = y

func setCells(data):
	for x in range(height):
		for y in range(width):
			set_cell(x, y, data[x][y])
