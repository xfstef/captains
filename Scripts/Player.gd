extends Node2D

# Player data
var my_id = 0
var my_name
var my_armies = []
var my_towns = []
var my_explored_tiles = []
var explored_masses = []
var my_visible_tiles = []
var los_points = []
var my_color = 0
# Global Instances
var adventure_map

func registerLOSPoint(x_y, los_range):
	for point in los_points:
		if point.x_y == x_y:
			point.los_range = los_range
			return
	los_points.append({x_y = x_y, los_range = los_range})

#TODO Make sure the lost LOS point is taken correctly into account.
func removeLOSPoint(x_y):
	for point in los_points:
		if point.x_y == x_y:
			los_points.erase(point)
			break

func updateLOSPoint(old_x_y, new_x_y, los_range):
	for x in range(los_points.size()):
		var point = los_points[x]
		if point.x_y == old_x_y:
			point.x_y = new_x_y
			point.los_range = los_range
			updateExploredTiles(point, x)
			adventure_map.fowTileMap.updateVisibility(my_id)
			return

func updateExploredTiles(point, x_pos):
	if my_visible_tiles.size() < x_pos + 1:
		my_visible_tiles.append([])
		my_visible_tiles[x_pos] = []
	my_visible_tiles[x_pos].clear()
	var current_mass = -1
	for z in range(explored_masses.size()):
		if explored_masses[z].find(point.x_y) > -1:
			current_mass = z
			break
	if current_mass == -1:
		explored_masses.append([])
		current_mass = explored_masses.size() - 1
	
	for x in range(-point.los_range, point.los_range + 1):
		for y in range(-point.los_range, point.los_range + 1):
			var new_point = Vector2(point.x_y.x + x, point.x_y.y + y)
			my_visible_tiles[x_pos].append(new_point)
			if my_explored_tiles.find(new_point) == -1:
				my_explored_tiles.append(new_point)
				explored_masses[current_mass].append(new_point)
				if explored_masses[current_mass].size() == 1:
					registerExploredMassIndex(point.x_y, current_mass)
				for u in range(explored_masses.size()):
					if u != current_mass && checkPointInOrAdjacentToGroup(new_point, explored_masses[u]) == true:
						explored_masses[current_mass] += explored_masses[u]
						explored_masses.remove(u)
						if current_mass > u:
							updateExploredMassIndexes(u, current_mass)
							current_mass -= 1
						else:
							updateExploredMassIndexes(current_mass, u)
						break
	adventure_map.propsTileMap.updateVisibility(my_visible_tiles)

func checkPointInOrAdjacentToGroup(point, group2):
	if group2.find(point) > -1 || isNeighbourOf(point, group2) == true:
		return true
	return false

func isNeighbourOf(point, group):
	var x_dif
	var y_dif
	for group_point in group:
		x_dif = abs(group_point.x) - abs(point.x)
		y_dif = abs(group_point.y) - abs(point.y)
		if x_dif > -2 && x_dif < 2 && y_dif > -2 && y_dif < 2:
			return true
	return false

func registerExploredMassIndex(x_y, index):
	for army in my_armies:
		if army.my_coords.x == x_y.x && army.my_coords.y == x_y.y:
			army.my_explored_mass = index

func updateExploredMassIndexes(new_index, old_index):
	for army in my_armies:
		if army.my_explored_mass == old_index:
			army.my_explored_mass = new_index

func getTileExploredMass(x_y):
	for x in range(explored_masses.size()):
		if explored_masses[x].find(x_y) > -1:
			return x
	return -1
