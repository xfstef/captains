extends Node2D

var my_animation
var move_coords
var selected_coords
var my_coords
var tween
var camera
var travel_type = 0
var fastest_path = []
var adventure_map
var executeMoveCommand = false
var currentMoveCommandStep = 0
var my_flooded_tiles = []
var tm_movement

func _ready():
	my_animation = get_node("AnimatedSprite")
	move_coords = Vector2(self.position.x, self.position.y)
	selected_coords = Vector2(0, 0)
	tween = get_node("Tween")
	# TODO: Add a means of loading what type of travel this army does: Land march, Sailing, Flying, Tunneling.
	travel_type = 0
	adventure_map = get_node("/root/AdventureMap")
	for x in range(adventure_map.mapHeight):
		my_flooded_tiles.append([])
		for y in range(adventure_map.mapWidth):
			my_flooded_tiles[x].append([])
			my_flooded_tiles[x][y] = -1
	tm_movement = get_node("../../TM-Movement")
	if my_coords:
		my_flooded_tiles[my_coords.x][my_coords.y] = 0
		floodFillTiles(my_coords, 0)

func _process(delta):
	if !tween.is_active() && my_animation.playing:
		my_animation.playing = false
		my_animation.frame = 0
		my_coords = adventure_map.propsTileMap.world_to_map(self.position)
		#if !executeMoveCommand:
			#my_flooded_tiles[my_coords.x][my_coords.y] = 0
			#floodFillTiles(my_coords)
	
	if executeMoveCommand:
		moveTo(adventure_map.propsTileMap.map_to_world(Vector2(fastest_path[currentMoveCommandStep].x, fastest_path[currentMoveCommandStep].y)))
		currentMoveCommandStep += 1
		if fastest_path.size() >= currentMoveCommandStep:
			currentMoveCommandStep = 0
			executeMoveCommand = false

func moveTo(x_y):
	x_y.y += 37
	move_coords = x_y

	tween.interpolate_property(self, 'position', self.position, move_coords, 1, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()
	my_animation.playing = true
	adventure_map.camera.followNode(x_y)
	
func changeTravelType(new_travel_type):
	travel_type = new_travel_type

func calculateFastestPath(x, y):
	selected_coords.x = x
	selected_coords.y = y
	fastest_path.clear()
	fastest_path.push_back(Vector2(x, y))
	var shortest_path_found = 1000
	var x_y_diffs = getXYDiff(fastest_path[0].x, fastest_path[0].y)
		
	if (x_y_diffs.x > -2 || x_y_diffs.x < 2) && (x_y_diffs.y > -2 || x_y_diffs.y < 2):
		executeMoveCommand = true

func getXYDiff(f_p_x, f_p_y):
	var x_y_diffs = Vector2(0, 0)
	if f_p_x > my_coords.x:
		x_y_diffs.x = f_p_x - my_coords.x
	elif f_p_x < my_coords.x:
		x_y_diffs.x = my_coords.x - f_p_x
	else:
		 x_y_diffs.x = my_coords.x
	if f_p_y > my_coords.y:
		x_y_diffs.y = f_p_y - my_coords.y
	elif f_p_y < my_coords.y:
		x_y_diffs.y = my_coords.y - f_p_y
	else:
		 x_y_diffs.y = my_coords.y
	
	return x_y_diffs

func floodFillTiles(start_coords, previous_node_cost):
	if start_coords:
		var x_search = start_coords.x + 1
		var y_search = start_coords.y - 1
		floodFillHelper(x_search, y_search, previous_node_cost)
		x_search = start_coords.x + 1
		y_search = start_coords.y
		floodFillHelper(x_search, y_search, previous_node_cost)
		x_search = start_coords.x + 1
		y_search = start_coords.y + 1
		floodFillHelper(x_search, y_search, previous_node_cost)
		x_search = start_coords.x
		y_search = start_coords.y + 1
		floodFillHelper(x_search, y_search, previous_node_cost)
		x_search = start_coords.x - 1
		y_search = start_coords.y + 1
		floodFillHelper(x_search, y_search, previous_node_cost)
		x_search = start_coords.x - 1
		y_search = start_coords.y
		floodFillHelper(x_search, y_search, previous_node_cost)
		x_search = start_coords.x - 1
		y_search = start_coords.y - 1
		floodFillHelper(x_search, y_search, previous_node_cost)
		x_search = start_coords.x
		y_search = start_coords.y - 1
		floodFillHelper(x_search, y_search, previous_node_cost)

func floodFillHelper(x, y, p_n_c):
	var cell_movement_type = tm_movement.get_cell(x, y)
	if x >= 0 && x < adventure_map.mapWidth && y >= 0 && y < adventure_map.mapHeight:
			if cell_movement_type == travel_type || cell_movement_type == 3:
				var new_cost = tm_movement.tile_move_expense[x][y] + p_n_c
				if my_flooded_tiles[x][y] == -1 || my_flooded_tiles[x][y] > new_cost:
					my_flooded_tiles[x][y] = new_cost
			else:
				my_flooded_tiles[x][y] = 0
