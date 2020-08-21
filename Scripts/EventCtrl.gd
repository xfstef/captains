extends Node2D

var adventure_map
var rng

# Called when the node enters the scene tree for the first time.
func _ready():
	adventure_map = get_node("/root/AdventureMap")
	rng = RandomNumberGenerator.new()

func parseEventAction(specs, name, army, object, eventPanel):
	var resources_changes = {}
	var result = null
	match name:
		"Salvage":
			rng.randomize()
			result = "You've found"
			for item in specs:
				var random_modifier = rng.randi_range(-2, 1)
				resources_changes[item] = specs.get(item) + random_modifier
				result = result + " " + String(resources_changes[item]) + " " + String(item) 
		"Explore":
			print(specs)
		"Retreat":
			eventPanel.object_triggered.npcWon(-1)
			eventPanel.eventButtonClicked(-1)
		"Capture":
			object.my_flag_i_sprite.frame = adventure_map.current_player_istance.my_color
			var resource_type = String(specs.keys()[0])
			var resource_amount = String(specs.values()[0])
			result = "This mine will now generate " + resource_amount + " " + resource_type + " every day."
		"Plunder":
			var resource_type = String(specs.keys()[0])
			var resource_amount = String(specs.values()[0])
			resources_changes[resource_type] = specs.values()[0]
			result = "After looting everything you could find, you've gained " + resource_amount + " " + resource_type + "."
	
	eventPanel.showResult(result)
	
	if resources_changes.size() > 0:
		army.modifyCache(resources_changes)
