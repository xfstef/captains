extends Node2D

# Player data
var my_id = 0
var my_name
var my_armies = []
var my_towns = []
var my_explored_tiles = []
var my_visible_tiles = []
var los_points = []
# Global Instances
var adventure_map

func registerLOSPoint(x_y, los_range):
	for point in los_points:
		if point.x_y == x_y:
			point.los_range = los_range
			return
	los_points.append({x_y = x_y, los_range = los_range})

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
	for x in range(-point.los_range, point.los_range + 1):
		for y in range(-point.los_range, point.los_range + 1):
			var new_point = Vector2(point.x_y.x + x, point.x_y.y + y)
			my_visible_tiles[x_pos].append(new_point)
			if my_explored_tiles.find(new_point) == -1:
				my_explored_tiles.append(new_point)
