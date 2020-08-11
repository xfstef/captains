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

func setCells(data, editor_enabled):
	var cell_type
	var prop_props
	for x in range(height):
		for y in range(width):
			cell_type = String(data[x][y])
			if !editor_enabled && cell_type in adventure_map.mapInteractables:
				prop_props = null
				prop_props = adventure_map.mapInteractables.get(cell_type)
				var the_properties = { x = x, y = y, cell_id = cell_type }
				if "unit_id" in prop_props:
					set_cell(x, y, -1)
					the_properties["unit_id"] = prop_props.get("unit_id")
				else:
					the_properties["name"] = prop_props.get("name")
					the_properties["frequency"] = prop_props.get("frequency")
					the_properties["still_valid"] = true
					the_properties["visited_by"] = []
					if "animation" in prop_props:
						set_cell(x, y, -1)
						the_properties["animation"] = prop_props.get("animation")
						the_properties["adventure_map_offset"] = prop_props.get("adventure_map_offset")
					else:
						set_cell(x, y, data[x][y])
				interactable_props.append(the_properties)
			else:
				set_cell(x, y, data[x][y])

func markVisited(x, y, army_id, player_id):
	for prop in interactable_props:
		if prop.x == x && prop.y == y:
			match prop.frequency:
				0.0:
					prop.stillValid = false
					prop.visitedBy.append({p_id = player_id, a_id = army_id})
				1.0:
					prop.visitedBy.append({p_id = player_id, a_id = army_id})
			return

func getPropStilValid(x, y, army_id, player_id):
	for prop in interactable_props:
		if prop.x == x && prop.y == y:
			match prop.frequency:
				0.0:
					return prop.stillValid
				1.0:
					for army in prop.visitedBy:
						if army.a_id == army_id && army.p_id == player_id:
							return false
					return true
