extends TileMap

var width
var height

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func initEmpty(w, h):
	width = w
	height = h
	for x in range(-w +1, w -1):
		for y in range(-h +1, h -1):
			if abs(x) + abs(y) < w and abs(x) + abs(y) < h:
				set_cell(x,y, 0)
