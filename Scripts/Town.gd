extends Node

var my_coords
var l_o_s_range = 3
var adventure_map
var current_land_mass
var my_id
var my_player_id
var currently_selected = false
var top_panel
var travel_type = -1
var adventure_event

var my_cache = {
	lumber = 0,
	stone = 0,
	steam = 0,
	iron = 0,
	gems = 0,
	shards = 0,
	gold = 0
}
var my_buildings = {}

func _ready():
	adventure_map = get_node("/root/AdventureMap")
	adventure_event = adventure_map.adventure_event
	top_panel = adventure_map.topPanel

func enterTown(army):
	print(army)
