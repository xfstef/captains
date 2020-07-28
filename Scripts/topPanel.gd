extends Panel

var current_lumber
var current_stone
var current_steam
var current_iron
var current_gems
var current_shards
var current_gold

func _ready():
	current_lumber = get_node("GridContainer/lumber/Label")
	current_stone = get_node("GridContainer/stone/Label")
	current_steam = get_node("GridContainer/steam/Label")
	current_iron = get_node("GridContainer/iron/Label")
	current_gems = get_node("GridContainer/gems/Label")
	current_shards = get_node("GridContainer/shards/Label")
	current_gold = get_node("GridContainer/gold/Label")

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
