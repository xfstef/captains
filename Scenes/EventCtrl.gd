extends Node2D

var adventure_map
var rng

# Called when the node enters the scene tree for the first time.
func _ready():
	adventure_map = get_node("/root/AdventureMap")
	rng = RandomNumberGenerator.new()

func parseEventAction(specs, name, army, eventPanel):
	match name:
		"Salvage":
			rng.randomize()
			var resources_changes = {}
			var result = "You've found"
			for item in specs:
				var random_modifier = rng.randi_range(-2, 1)
				resources_changes[item] = specs.get(item) + random_modifier
				result = result + " " + String(resources_changes[item]) + " " + String(item) 
			army.modifyCache(resources_changes)
			eventPanel.showResult(result)
		"Explore":
			print(specs)
