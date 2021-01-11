extends TileMap

var width
var height

func setSize(x, y):
	width = x
	height = y

func setCells(data):
	for cell in data:
		set_cell(cell[0], cell[1], cell[2])
#	for x in range(height):
#		for y in range(width):
#			set_cell(x, y, data[x][y][0])
