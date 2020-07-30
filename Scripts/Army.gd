extends Node2D

var my_animation
var move_coords
var selected_coords
var my_coords
var tween
var camera
var travel_type = 0
var fastest_path = []
var line_of_sight = []
var l_o_s_range = 2
var adventure_map
var executeMoveCommand = false
var currentMoveCommandStep = 1
var tm_movement
var tm_fow
var current_land_mass
var my_id
var my_frame_id
var my_player_id
var my_movement_points
var my_remaining_movement_today
var mouse_controller
var current_prop_code = -1
var currently_selected = false
var my_cache = {
	"lumber": 0,
	"stone": 0,
	"steam": 0,
	"iron": 0,
	"gems": 0,
	"shards": 0,
	"gold": 0
}
var top_panel

func _ready():
	my_animation = get_node("AnimatedSprite")
	move_coords = Vector2(self.position.x, self.position.y)
	selected_coords = Vector2(0, 0)
	tween = get_node("Tween")
	# TODO: Add a means of loading what type of travel this army does: Land march, Sailing, Flying, Tunneling.
	travel_type = 0
	adventure_map = get_node("/root/AdventureMap")
	top_panel = adventure_map.topPanel
	tm_movement = get_node("../../TM-Movement")
	tm_fow = get_node("../../TM-FOW")
	my_movement_points = 100
	my_remaining_movement_today = 100
	mouse_controller = get_node("../../MouseCtrl")

func _physics_process(delta):
	if !tween.is_active():
		if my_animation.playing:
			my_animation.playing = false
			my_animation.frame = 0
			my_coords = adventure_map.propsTileMap.world_to_map(self.position)
			updateLOS(false)
			if currentMoveCommandStep == 1:
				current_prop_code = adventure_map.propsTileMap.get_cell(my_coords.x, my_coords.y)
				if current_prop_code == -1 && adventure_map.getArmyPresent(my_coords):
					current_prop_code = 0
		
		if executeMoveCommand:
			var step = fastest_path[0]
			if step.move_cost <= my_remaining_movement_today:
				moveTo(adventure_map.propsTileMap.map_to_world(Vector2(step.x, step.y)), step.move_cost)
				currentMoveCommandStep += 1
				adventure_map.clearMovementTracker(step.x, step.y)
				top_panel.updateMovementLeft(my_remaining_movement_today)
				fastest_path.remove(0)
				if fastest_path.size() == 0:
					currentMoveCommandStep = 1
					executeMoveCommand = false
		
		if current_prop_code > -1 && adventure_map.propsTileMap.getPropStilValid(my_coords.x, my_coords.y, my_id, my_player_id) == true:
			adventure_map.interactWithObject(my_coords, my_id)
			current_prop_code = -1

func _input(event):
	if event is InputEventMouseButton && event.is_pressed() == true && event.button_index == 1 || event is InputEventKey:
		executeMoveCommand = false

func moveTo(x_y, cost):
	x_y.y += 37
	move_coords = x_y
	my_remaining_movement_today -= cost
	tween.interpolate_property(self, 'position', self.position, move_coords, 1, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()
	my_animation.playing = true
	adventure_map.camera.followNode(x_y)

func changeTravelType(new_travel_type):
	travel_type = new_travel_type

func calculateFastestPath(x, y):
	currentMoveCommandStep = 1
	executeMoveCommand = false
	selected_coords.x = x
	selected_coords.y = y
	fastest_path.clear()
	aStarSearch(x, y)
	adventure_map.drawPath(my_id)

func aStarSearch(x, y):
	var open_nodes = []
	open_nodes.append({x = my_coords.x, y = my_coords.y, g_cost = 0, h_cost = 0, f_cost = 0, parent = {}})
	var evaluated_nodes = []
	var current_node
	
	while open_nodes.size() > 0:
		var current_lowest_node_index = getLowestFCostNode(open_nodes)
		current_node = open_nodes[current_lowest_node_index]
		evaluated_nodes.append(open_nodes[current_lowest_node_index])
		open_nodes.remove(current_lowest_node_index)
		
		if current_node.x == selected_coords.x && current_node.y == selected_coords.y:
			while current_node.parent:
				fastest_path.push_front({x = current_node.x, y = current_node.y, move_cost = tm_movement.tile_move_expense[current_node.x][current_node.y]})
				current_node = current_node.parent
			return
		
		var neighbour_pos = adventure_map.getNodeNeighbours(current_node, travel_type, current_land_mass)
		var node_neighbours = prepNeighbours(neighbour_pos, open_nodes)
		
		for x in range(node_neighbours.size()):
			if !evaluated_nodes.has(node_neighbours[x]):
				var newMoveCostToNeightbour = current_node.g_cost + calcDistanceOf2Nodes(current_node, node_neighbours[x], tm_movement.tile_move_expense[node_neighbours[x].x][node_neighbours[x].y])
				if newMoveCostToNeightbour < node_neighbours[x].g_cost || !open_nodes.has(node_neighbours[x]):
					node_neighbours[x].g_cost = newMoveCostToNeightbour
					node_neighbours[x].h_cost = calcDistanceOf2Nodes(node_neighbours[x], selected_coords, 10)
					node_neighbours[x].f_cost = node_neighbours[x].g_cost + node_neighbours[x].h_cost
					node_neighbours[x].parent = current_node
					if !open_nodes.has(node_neighbours[x]):
						open_nodes.append(node_neighbours[x])

func getLowestFCostNode(temp_list):
	var lowest = 0
	for x in range(1, temp_list.size()):
		if temp_list[lowest].f_cost > temp_list[x].f_cost || temp_list[lowest].f_cost == temp_list[x].f_cost && temp_list[lowest].h_cost > temp_list[x].h_cost:
			lowest = x
	
	return lowest

func prepNeighbours(positions, open_nodes):
	var neighbours = []
	for x in range(positions.size()):
		var node_found = false
		for y in range(open_nodes.size()):
			if positions[x].x == open_nodes[y].x && positions[x].y == open_nodes[y].y:
				neighbours.append(open_nodes[y])
				node_found = true
				break
		if !node_found:
			neighbours.append({x = positions[x].x, y = positions[x].y, g_cost = 0, h_cost = 0, f_cost = 0, parent = {}})
		
	return neighbours

func calcDistanceOf2Nodes(node_a, node_b, cost):
	var distance_x = abs(node_a.x - node_b.x)
	var distance_y = abs(node_a.y - node_b.y)
	
	return cost * (distance_x + distance_y) + ((1.2 * cost) - (2 * cost)) * min(distance_x, distance_y)

func modifyCache(resources_changes):
	for change in resources_changes:
		var new_amount = my_cache.get(change) + resources_changes.get(change)
		my_cache[change] = new_amount
	if currently_selected == true:
		top_panel.updateCache(my_cache)

func updateLOS(initial_load):
	line_of_sight.clear()
	for x in range(-l_o_s_range, l_o_s_range + 1):
		for y in range(-l_o_s_range, l_o_s_range + 1):
			line_of_sight.append(Vector2(my_coords.x + x, my_coords.y + y))
	if initial_load != true:
		tm_fow.updatePlayerVisibility(my_player_id, my_id)
