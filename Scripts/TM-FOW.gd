extends TileMap

var adventure_map
var tm_props
var player_visibilities = []
var width
var height
var current_player = 0
var player_explored_tiles
var player_visible_tiles

func _ready():
	adventure_map = get_node("/root/AdventureMap")
	tm_props = get_node("/root/AdventureMap/TM-Props")

func setSize(x, y):
	width = x
	height = y

func updateVisibility(player_id):
	current_player = player_id
	player_explored_tiles = adventure_map.player_instances[current_player].my_explored_tiles
	player_visible_tiles = adventure_map.player_instances[current_player].my_visible_tiles
	for x in range(width):
		for y in range(height):
			if player_explored_tiles.find(Vector2(x, y)) == -1:
				set_cell(x, y, 1)
			elif player_visible_tiles.find(Vector2(x, y)) == -1:
				set_cell(x, y, 16)
			else:
				set_cell(x, y, -1)

#func addPlayerVisibility(player_id):
#	var player_visible_tiles = getPlayerVisibleTiles(player_id)
#	#print(player_id, player_visible_tiles)
#	player_visibilities.append([])
#	player_visibilities[player_id] = []
#	for x in range(width):
#		player_visibilities[player_id].append([])
#		player_visibilities[player_id][x] = []
#		for y in range(height):
#			player_visibilities[player_id][x].append([])
#			if player_visible_tiles.find(Vector2(x, y)) == -1:
#				player_visibilities[player_id][x][y] = 1
#			else:
#				player_visibilities[player_id][x][y] = -1
#
#func getPlayerVisibleTiles(player_id):
#	var return_tiles = []
#	var player_armies = adventure_map.player_instances[player_id].my_armies
#	for army in player_armies:
#		for l_o_s in army.line_of_sight:
#			if return_tiles.find(l_o_s) == -1:
#				return_tiles.append(l_o_s)
#	return return_tiles
#	# TODO: Add towns and other view generating objects to this calculation
#
#func updatePlayerVisibility(player_id, army_id):
#	var player_vis = player_visibilities[player_id]
#	var army = adventure_map.player_instances[player_id].my_armies[army_id]
#	for tile in army.line_of_sight:
#		var tile_vis = player_vis[tile.x][tile.y]
#		if tile_vis != -1:
#			player_vis[tile.x][tile.y] = -1
#			set_cell(tile.x, tile.y, player_vis[tile.x][tile.y])
