extends Node2D

# Paths
var mapPath = "res://Maps/test1.json"
var interactablesPath = "res://Data/mapInteractables.json"
var directionIndexesPath = "res://Data/directionIndexes.json"
var mapMoveIndesexPath = "res://Data/mapMoveIndexes.json"
#var unitsPath = "res://Data/units.json"
var captainsPath = "res://Data/captains.json"
var dayEventsPath = "res://Data/dayEvents.json"
# Parameters
var EconomicDifficulty
var AIDifficulty
var MonsterDifficulty = 1
# World Object References
var camera
var groundTileMap
var propsTileMap
var movementTileMap
var fowTileMap
var mouseCtrl
var info
var moveTracker
var mapCreator
var armiesListContainer
var armyButton
var townsContainer
var townButton
var eventCtrl
var unitsContainer
var topPanel
var turnPanel
var player
# Instanced Objects
var player_instances = []
var movement_trackers = []
var action_names = []
var action_specs = []
var captains_DB
#var selected_army_instance
#var selected_town_instance
var current_selection_instance
var current_player_instance
var day_events
var townObject = load("res://Scenes/Town.tscn")
var armyObject = load("res://Scenes/Army.tscn")
# Availables Scenes
var adventure_event
var new_day_event
# Other
var mapWidth = 0
var mapHeight = 0
#var selected_army = { player_id = -1, army_id = -1}
#var selected_town = { player_id = -1, town_id = -1}
var current_selection = {player_id = -1, entity_id = -1}
var command_given = false
var current_player = 0
var rng
var directionIndexes = {}
var mapMoveIndexes = {}
var mapInteractables = {}
# TODO: Add total players objects and instance them at start
# Also add total player armies within each player instance
#var total_players

# Called when the node enters the scene tree for the first time.
func _ready():
	camera = get_node("Camera2D")
	groundTileMap = get_node("TM-Ground")
	propsTileMap = get_node("TM-Props")
	movementTileMap = get_node("TM-Movement")
	fowTileMap = get_node("TM-FOW")
	mouseCtrl = get_node("MouseCtrl")
	info = get_node("UI/info")
	moveTracker = get_node("MovementTracker")
	mapCreator = get_node("UI")
	armiesListContainer = get_node("UI/ArmiesContainer/ArmiesList")
	armyButton = get_node("ArmyButton")
	townsContainer = get_node("UI/TownsContainer/TownsList")
	townButton = get_node("TownButton")
	directionIndexes = loadFilePayload(directionIndexesPath)
	mapMoveIndexes = loadFilePayload(mapMoveIndesexPath)
	mapInteractables = loadFilePayload(interactablesPath)
	captains_DB = loadFilePayload(captainsPath)
	adventure_event = get_node("UI/AdventureEvent")
	eventCtrl = get_node("EventCtrl")
	unitsContainer = get_node("UI/UnitsContainer")
	topPanel = get_node("UI/topPanel")
	turnPanel = get_node("UI/TurnPanel")
	player = get_node("Player")
	rng = RandomNumberGenerator.new()
	loadMapData(mapCreator.showEditor)
	day_events = loadFilePayload(dayEventsPath)
	new_day_event = get_node("UI/NewDayEvent")
	new_day_event.setNewDay(turnPanel.turn_label_string, null)

func prepCamera():
	var half_width_pixels = (mapWidth / 2) * 144
	var half_height_pixels = (mapHeight / 2) * 72
	camera.limit_left = (half_width_pixels * -1) - 200
	camera.limit_top = (half_height_pixels * -1 ) - 120
	camera.limit_right = half_width_pixels + 200
	camera.limit_bottom = half_height_pixels + 192

func loadFilePayload(fileName):
	var file = File.new()
	if not file.file_exists(fileName):
		return
	file.open(fileName, File.READ)
	var payload = parse_json(file.get_as_text())
	file.close()
	return payload

func loadMapData(editor_mode):
	var payload
	if editor_mode == true:
		mapWidth = mapCreator.data.width
		mapHeight = mapCreator.data.height
	else:
		payload = loadFilePayload(mapPath)
		mapWidth = payload.width
		mapHeight = payload.height
	mouseCtrl.mapWidth = mapWidth
	mouseCtrl.mapHeight = mapHeight
	prepCamera()
	groundTileMap.setSize(mapWidth, mapHeight)
	propsTileMap.setSize(mapWidth, mapHeight)
	movementTileMap.setSize(mapWidth, mapHeight)
	fowTileMap.setSize(mapWidth, mapHeight)
	
	if editor_mode == true:
		mapCreator.readMapData()
		payload = mapCreator.data
	
	groundTileMap.setCells(payload.tiles)
	propsTileMap.setCells(payload.tiles, editor_mode, payload.npcs)
	movementTileMap.setCells(payload.tiles)
	
	for z in range(payload.playerStartRules.size()):
		var new_player = player.duplicate()
		new_player.my_id = z
		new_player.adventure_map = self
		new_player.my_color = payload.playerStartRules[z].color
		player_instances.append(new_player)
		if payload.playerStartRules[z].get("armies"):
			instantiate_player_armies(z, payload.playerStartRules[z].armies)
		if payload.playerStartRules[z].get("castles"):
			instantiate_player_towns(z, payload.playerStartRules[z].castles)
	
	current_player_instance = player_instances[current_player]
	armiesListContainer.switchPlayer(current_player)
	townsContainer.switchPlayer(current_player)
	fowTileMap.updateVisibility(current_player)

func instantiate_player_armies(player_nr, player_armies):
	for h in range(player_armies.size()):
		var new_army = armyObject.instance()
		player_instances[player_nr].my_armies.append([])
		player_instances[player_nr].my_armies = []
		player_instances[player_nr].my_armies.append(new_army)
		
		var pos = Vector2(player_armies[h].x, player_armies[h].y)
		new_army.my_coords = pos
		new_army.position = propsTileMap.map_to_world(pos)
		new_army.position.y += 36
		new_army.current_land_mass = movementTileMap.getLandMassOfCell(pos.x, pos.y)
		new_army.my_id = h
		new_army.my_frame_id = player_armies[h].heroId
		new_army.my_player_id = player_nr
		propsTileMap.add_child(new_army)
		if "cameraStartPosition" in player_armies[h] && player_armies[h].cameraStartPosition == true:
			camera.followNode(new_army.position)
		var army_cache = player_armies[h].get("cache")
		if "selected" in player_armies[h] && player_armies[h].selected == true:
			current_selection.entity_id = h
			current_selection_instance = new_army
			current_selection_instance.currently_selected = true
			topPanel.updateMovementLeft(current_selection_instance.my_remaining_movement_today)
		if "cache" in player_armies[h]:
			new_army.modifyCache(army_cache)
		player_instances[player_nr].registerLOSPoint(pos, new_army.l_o_s_range)
		player_instances[player_nr].updateLOSPoint(pos, pos, new_army.l_o_s_range)
		if "general_skills" in player_armies[h]:
			new_army.modifyGeneralSkills(player_armies[h].general_skills)
		
		armiesListContainer.add_child(armyButton.duplicate())
		armiesListContainer.get_child(h).my_player_id = player_nr
		armiesListContainer.get_child(h).my_army_id = h
		armiesListContainer.get_child(h).setFrameID(player_armies[h].heroId)

func instantiate_player_towns(player_nr, player_towns):
	for h in range(player_towns.size()):
		#var new_town = townObject.instance()
		var pos = Vector2(player_towns[h].x, player_towns[h].y)
		var new_town = propsTileMap.findInteractable(pos)
		#new_town.my_coords = pos
		#new_town.position = propsTileMap.map_to_world(pos)
		new_town.current_land_mass = movementTileMap.getLandMassOfCell(pos.x, pos.y)
		new_town.my_id = player_towns[h].townId
		#new_town.my_player_id = player_nr
		if "selected" in player_towns[h] && player_towns[h].selected == true:
			current_selection.entity_id = h
			current_selection_instance = new_town
			current_selection_instance.currently_selected = true
		
		addTownToPlayer(player_nr, new_town, pos)

func addTownToPlayer(player_nr, new_town, pos):
	player_instances[player_nr].my_towns.append([])
	player_instances[player_nr].my_towns = []
	player_instances[player_nr].my_towns.append(new_town)	
	player_instances[player_nr].registerLOSPoint(pos, new_town.l_o_s_range)
	player_instances[player_nr].updateLOSPoint(pos, pos, new_town.l_o_s_range)
	new_town.setFlag(player_instances[player_nr].my_color, player_instances[player_nr].my_id)
	addTownToTownsContainer(player_nr, new_town.my_id)

func removeTownFromPlayer(old_owner, town):
	for town in player_instances[old_owner].my_towns:
		if town.my_player_id != old_owner:
			player_instances[old_owner].my_towns.erase(town)
			break
	
	for town_button in townsContainer.get_children():
		if town_button.my_town_id == town.my_id:
			town_button.my_player_id = town.my_player_id
			break
	
	player_instances[old_owner].removeLOSPoint(town.my_coords)

func addTownToTownsContainer(player_id, town_id):
	var new_town_button = townButton.duplicate()
	townsContainer.add_child(new_town_button)
	new_town_button.my_player_id = player_id
	new_town_button.my_town_id = town_id
	new_town_button.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):

func _unhandled_input(event):
	if camera.tween.is_active() || mouseCtrl.pointerState == 5 || current_selection_instance.travel_type == -1:
		return
	
	var p_a_s_x = current_selection_instance.my_coords.x
	var p_a_s_y = current_selection_instance.my_coords.y
	var army_land_mass = current_selection_instance.current_land_mass
	var army_travel_type = current_selection_instance.travel_type
	
	if event is InputEventKey && event.pressed == false:
		var d_modifier = establishMapMoveDirectionModifiers(event.scancode)
		if d_modifier == null:
			return
		
		if isTileAccessible(p_a_s_x + d_modifier.x, p_a_s_y + d_modifier.y, army_travel_type, army_land_mass):
			clearMovementTrackers()
			current_selection_instance.calculateFastestPath(p_a_s_x + d_modifier.x, p_a_s_y + d_modifier.y)
			current_selection_instance.executeMoveCommand = true
	
	elif event is InputEventMouseButton && event.is_pressed() == false && event.button_index == 1 && (mouseCtrl.pointerState == 0 || mouseCtrl.pointerState == 2):
		var tile = groundTileMap.world_to_map(get_global_mouse_position())
		if (tile.x != p_a_s_x || tile.y != p_a_s_y) && isTileAccessible(tile.x, tile.y, army_travel_type, army_land_mass):
			if current_selection_instance.selected_coords == tile:
				current_selection_instance.executeMoveCommand = true
			else:
				clearMovementTrackers()
				current_selection_instance.calculateFastestPath(tile.x, tile.y)

# TODO: Improve this function so that it takes into consideration the army travel type and land masses and portals
func isTileAccessible(x, y, travel_type, land_mass):
#	if x < -mapWidth || x > mapWidth || y < -mapHeight || y > mapHeight:
#		return false
	var target_land_mass = movementTileMap.getLandMassOfCell(x, y)
	if target_land_mass == - 1:
		return false
	elif land_mass != target_land_mass:
		return false
	elif travel_type == 0:
		if movementTileMap.get_cell(x,y) == 0 || movementTileMap.get_cell(x,y) == 3:
			return true
		else:
			return false
	elif travel_type == 1:
		if movementTileMap.get_cell(x,y) == 1 || movementTileMap.get_cell(x,y) == 3:
			return true
		else:
			return false
	else:
		return false

func getNodeNeighbours(node, army_travel_type, land_mass):
	var valid_neighbours = []
	var new_x
	var new_y
	
	for x in range(-1, 2):
		for y in range(-1, 2):
			if !(x == 0 && y == 0):
				new_x = node.x + x
				new_y = node.y + y
				if isTileAccessible(new_x, new_y, army_travel_type, land_mass):
					valid_neighbours.append(Vector2(new_x, new_y))
	
	return valid_neighbours

func drawPath(army_id):
	var nodes = current_selection_instance.fastest_path
	var army_range = current_selection_instance.my_remaining_movement_today
	var current_cost = 0
	for x in range(nodes.size()):
		current_cost += nodes[x].move_cost
		if movement_trackers.size() < x + 1:
			movement_trackers.append(moveTracker.duplicate())
			propsTileMap.add_child(movement_trackers[x])
		movement_trackers[x].position = propsTileMap.map_to_world(Vector2(nodes[x].x, nodes[x].y))
		movement_trackers[x].position.y += 36
		movement_trackers[x].tile_x = nodes[x].x
		movement_trackers[x].tile_y = nodes[x].y
		if current_cost > army_range:
			movement_trackers[x].setEnabled(false)
		else:
			movement_trackers[x].setEnabled(true)
		if x + 1 < nodes.size():
			if x != 0:
				movement_trackers[x].setTrackerIndex(establishDirection(nodes[x - 1], nodes[x], nodes[x + 1], army_id))
			else:
				movement_trackers[x].setTrackerIndex(establishDirection({x = current_selection_instance.my_coords.x, y = current_selection_instance.my_coords.y}, nodes[x], nodes[x + 1], army_id))
		else:
			movement_trackers[x].setTrackerIndex(40)
		movement_trackers[x].visible = true

func clearMovementTrackers():
	for tracker in movement_trackers:
		tracker.visible = false

func clearMovementTracker(searched_x, searcher_y):
	for tracker in movement_trackers:
		if tracker.tile_x == searched_x && tracker.tile_y == searcher_y:
			tracker.visible = false
			return

func establishDirection(n_1, n_2, n_3, army_id):
	var x_d_1 = String(n_1.x - n_2.x)
	var y_d_1 = String(n_1.y - n_2.y)
	var x_d_2 = String(n_3.x - n_2.x)
	var y_d_2 = String(n_3.y - n_2.y)
	
	return directionIndexes.get(x_d_1).get(y_d_1).get(x_d_2).get(y_d_2)

func establishMapMoveDirectionModifiers(key_stroke):
	var modifiers = mapMoveIndexes.get(String(key_stroke))
	if modifiers != null:
		return Vector2(modifiers[0], modifiers[1])
	return null

func newSelected(the_id, armyOrTown):
	var old_id = current_selection.entity_id
	current_selection_instance.currently_selected = false
	current_selection.entity_id = the_id
	if armyOrTown == true:
		current_selection_instance = player_instances[current_player].my_armies[current_selection.entity_id]
	else:
		current_selection_instance = player_instances[current_player].my_towns[current_selection.entity_id]
	current_selection_instance.currently_selected = true
	topPanel.updateCache(current_selection_instance.my_cache)
	if current_selection_instance.travel_type != -1 && old_id != the_id:
		topPanel.updateMovementLeft(current_selection_instance.my_remaining_movement_today)
		clearMovementTrackers()
		if current_selection_instance.fastest_path.size() > 0:
			drawPath(the_id)
	camera.followNode(current_selection_instance.position)

func getArmyPresent(tile):
	for x in range(player_instances.size()):
		for y in range(player_instances[x].my_armies.size()):
			if y != current_selection.entity_id && player_instances[x].my_armies[y].my_coords == tile:
				return true
	return false

func endTurn(next_turn):
	playOtherPlayerTurns()
	turnPanel.setTurnLabel()
	var new_event = null
	for army in player_instances[current_player].my_armies:
		army.my_remaining_movement_today = army.my_movement_points
	if current_selection_instance.travel_type != -1:
		drawPath(current_selection.entity_id)
		topPanel.updateMovementLeft(current_selection_instance.my_remaining_movement_today)
	if day_events.get(String(turnPanel.current_day)) && day_events.get(String(turnPanel.current_day)).get(String(turnPanel.current_week)) && day_events.get(String(turnPanel.current_day)).get(String(turnPanel.current_week)).get(String(turnPanel.current_month)):
		new_event = day_events.get(String(turnPanel.current_day)).get(String(turnPanel.current_week)).get(String(turnPanel.current_month))
	new_day_event.setNewDay(turnPanel.turn_label_string, new_event)

func playOtherPlayerTurns():
	print("Other players are gaming")
