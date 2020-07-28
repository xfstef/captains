extends Panel

var current_lumber
var current_stone
var current_steam
var current_iron
var current_gems
var current_shards
var current_gold
var current_movement_left

func _ready():
	current_lumber = get_node("GridContainerLeft/lumber/Label")
	current_stone = get_node("GridContainerLeft/stone/Label")
	current_steam = get_node("GridContainerLeft/steam/Label")
	current_iron = get_node("GridContainerLeft/iron/Label")
	current_gems = get_node("GridContainerLeft/gems/Label")
	current_shards = get_node("GridContainerLeft/shards/Label")
	current_gold = get_node("GridContainerLeft/gold/Label")
	current_movement_left = get_node("GridContainerRight/movement/Label")

func updateCache(new_cache):
	for resource in new_cache:
		var the_amount = String(new_cache[resource])
		match resource:
			"lumber":
				current_lumber.text = the_amount
			"stone":
				current_stone.text = the_amount
			"steam":
				current_steam.text = the_amount
			"iron":
				current_iron.text = the_amount
			"gems":
				current_gems.text = the_amount
			"shards":
				current_shards.text = the_amount
			"gold":
				current_gold.text = the_amount

func updateMovementLeft(new_movement):
	current_movement_left.text = String(new_movement)
