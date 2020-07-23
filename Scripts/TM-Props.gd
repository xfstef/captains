extends TileMap

var width
var height
var interactable_props = []
var adventure_map

func _ready():
	adventure_map = get_parent()

func setSize(x, y):
	width = x
	height = y

func setCells(data):
	for x in range(height):
		for y in range(width):
			set_cell(x, y, data[x][y])
			var prop_props = adventure_map.map_interactables.get(String(data[x][y]))
			if prop_props != null:
				interactable_props.append({"x": x, "y": y, "frequency": prop_props.get("frequency"), "stillValid": true, "visitedBy": []})

func markVisited(x, y, army_id, player_id):
	for prop in interactable_props:
		if prop.x == x && prop.y == y:
			# TODO: See why match isn't working here and find a solution
			if prop.frequency == 0:
				prop.stillValid = false
				prop.visitedBy.append({"p_id": player_id, "a_id": army_id})
			return

func getPropStilValid(x, y, army_id, player_id):
	for prop in interactable_props:
		if prop.x == x && prop.y == y:
			return prop.stillValid
