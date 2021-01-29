extends TileMap

var adventure_map
var tm_props
var player_visibilities = []
var width
var height
var current_player = 0
var player_explored_tiles
var player_visible_tiles
var tm_movement

func _ready():
	adventure_map = get_node("/root/AdventureMap")
	tm_props = get_node("/root/AdventureMap/TM-Props")
	tm_movement = get_node("/root/AdventureMap/TM-Movement")

func setSize(x, y):
	width = x
	height = y

func updateVisibility(player_id):
	current_player = player_id
	player_explored_tiles = adventure_map.player_instances[current_player].my_explored_tiles
	player_visible_tiles = adventure_map.player_instances[current_player].my_visible_tiles
	var cell_type
	for x in range(-width + 1, width):
		for y in range(-height + 1, height):
			if tm_movement.getLandMassOfCell(x, y) > -1:
				if player_explored_tiles.find(Vector2(x, y)) == -1:
					cell_type = 1
				else:
					cell_type = findVisibleTile(x, y)
				set_cell(x, y, cell_type)

func findVisibleTile(x, y):
	for group in player_visible_tiles:
		if group.find(Vector2(x, y)) > -1:
			return -1
	return 16
