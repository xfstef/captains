extends TileMap

var unitsPath = "res://Data/units.json"

var width
var height
var npcs = []
var interactables = []
var adventure_map
var units_DB
var adventureMapUnit
var aMInteractable
var rng

func _ready():
	adventure_map = get_parent()
	units_DB = adventure_map.loadFilePayload(unitsPath)
	adventureMapUnit = adventure_map.adventureMapUnit
	aMInteractable = adventure_map.aMInteractable
	rng = RandomNumberGenerator.new()

func setSize(x, y):
	width = x
	height = y

func setCells(data, editor_enabled, npc_rules):
	var cell_type
	var prop_props
	for x in range(height):
		for y in range(width):
			cell_type = String(data[x][y])
			if !editor_enabled && cell_type in adventure_map.mapInteractables:
				prop_props = null
				prop_props = adventure_map.mapInteractables.get(cell_type)
				if "unit_id" in prop_props:
					set_cell(x, y, -1)
					var npc_props = units_DB[prop_props.unit_id]
					var new_npc = adventureMapUnit.instance()
					add_child(new_npc)
					new_npc.unit_name = npc_props.name
					new_npc.cell_id = cell_type
					new_npc.my_coords = Vector2(x, y)
					new_npc.position = map_to_world(new_npc.my_coords)
					var npc_rule = findNPCRules(npc_rules, new_npc.my_coords)
					if npc_rule != null && "amount" in npc_rule:
						new_npc.amount = npc_rule.amount
					else:
						#TODO: Implement unit_tier_modifier
						rng.randomize()
						new_npc.amount = adventure_map.MonsterDifficulty * rng.randi_range(5, 10) # + unit_tier_modifier
					new_npc.loadSprite(npc_props.sprite_name)
					new_npc.my_sprite.offset = Vector2(npc_props.adventure_map_offset[0], npc_props.adventure_map_offset[1])
					npcs.append(new_npc)
				else:
					var new_interactable = aMInteractable.instance()
					add_child(new_interactable)
					new_interactable.name = prop_props.name
					new_interactable.cell_id = cell_type
					new_interactable.my_coords = Vector2(x, y)
					new_interactable.position = map_to_world(new_interactable.my_coords)
					new_interactable.frequency = prop_props.frequency
					new_interactable.still_valid = true
					new_interactable.visited_by = []
					new_interactable.choices = prop_props.choices
					new_interactable.description = prop_props.description
					if "animation" in prop_props:
						set_cell(x, y, -1)
						new_interactable.loadSprite(prop_props.animation)
						new_interactable.my_sprite.offset = Vector2(prop_props.adventure_map_offset[0], prop_props.adventure_map_offset[1])
					else:
						set_cell(x, y, data[x][y])
					interactables.append(new_interactable)
			else:
				set_cell(x, y, data[x][y])

func findNPCRules(rules, x_y):
	for rule in rules:
		if rule.x == x_y.x && rule.y == x_y.y:
			return rule
	return null

func checkIfTileHasInteractable(x_y):
	for npc in npcs:
		if npc.my_coords == x_y:
			return npc
	for interactable in interactables:
		if interactable.my_coords == x_y:
			return interactable
	return null

func markVisited(x, y, army_id, player_id):
	for prop in interactables:
		if prop.my_coords.x == x && prop.my_coords.y == y:
			match prop.frequency:
				0.0:
					prop.still_valid = false
					prop.visited_by.append({p_id = player_id, a_id = army_id})
				1.0:
					prop.visited_by.append({p_id = player_id, a_id = army_id})
			return

func getPropStilValid(x, y, army_id, player_id):
	for prop in interactables:
		if prop.my_coords.x == x && prop.my_coords.y == y:
			match prop.frequency:
				0.0:
					return prop.still_valid
				1.0:
					for army in prop.visited_by:
						if army.a_id == army_id && army.p_id == player_id:
							return false
					return true

func updateVisibility(new_visible_tiles):
	var tile_found
	for npc in npcs:
		for group in new_visible_tiles:
			tile_found = group.find(npc.my_coords)
			if tile_found != -1:
				break
		if tile_found != -1:
			if npc.my_sprite.playing == false:
				npc.my_sprite.play("Idle", false)
		else:
			if npc.my_sprite.playing == true:
				npc.my_sprite.stop()
	
	for interactable in interactables:
		if interactable.my_animation != null:
			for group in new_visible_tiles:
				tile_found = group.find(interactable.my_coords)
				if tile_found != -1:
					break
			if tile_found != -1:
				if interactable.my_sprite.playing == false:
					interactable.my_sprite.play("Idle", false)
			else:
				if interactable.my_sprite.playing == true:
					interactable.my_sprite.stop()

