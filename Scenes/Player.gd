extends Node2D

# Player data
var my_id = 0
var my_name
var my_armies = []
var my_towns = []
var my_explored_tiles = []
var my_visible_tiles = []
# Global Instances
var adventure_map

func updateExploredTiles(line_of_sight):
	for sight in line_of_sight:
		if my_explored_tiles.find(sight) == -1:
			my_explored_tiles.append(sight)
	updateVisibleTiles()

func updateVisibleTiles():
	my_visible_tiles.clear()
	for army in my_armies:
		for sight in army.line_of_sight:
			if my_visible_tiles.find(sight) == -1:
				my_visible_tiles.append(sight)
	adventure_map.fowTileMap.updateVisibility(my_id)
