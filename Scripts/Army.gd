extends Node2D

var my_animation
var move_coords
var selected_coords
var my_coords
var tween
var camera
var travel_type = 0
var fastest_path = []
var adventure_map
var executeMoveCommand = false
var currentMoveCommandStep = 0

func _ready():
	my_animation = get_node("AnimatedSprite")
	move_coords = Vector2(self.position.x, self.position.y)
	selected_coords = Vector2(0, 0)
	tween = get_node("Tween")
	# TODO: Add a means of loading what type of travel this army does: Land march, Sailing, Flying, Tunneling.
	travel_type = 0
	adventure_map = get_node("/root/AdventureMap")

func _process(delta):
	if !tween.is_active() && my_animation.playing:
		my_animation.playing = false
		my_animation.frame = 0
		my_coords = adventure_map.propsTileMap.world_to_map(self.position)
	
	if executeMoveCommand:
		moveTo(adventure_map.propsTileMap.map_to_world(Vector2(fastest_path[currentMoveCommandStep].x, fastest_path[currentMoveCommandStep].y)))
		currentMoveCommandStep += 1
		if fastest_path.size() >= currentMoveCommandStep:
			currentMoveCommandStep = 0
			executeMoveCommand = false

func moveTo(x_y):
	x_y.y += 37
	move_coords = x_y

	tween.interpolate_property(self, 'position', self.position, move_coords, 1, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()
	my_animation.playing = true
	adventure_map.camera.followNode(x_y)
	
func changeTravelType(new_travel_type):
	travel_type = new_travel_type

func calculateFastestPath(x, y):
	selected_coords.x = x
	selected_coords.y = y
	fastest_path.clear()
	fastest_path.push_back(Vector2(x, y))
	var shortest_path_found = 1000
	
	var x_diff
	var y_diff
	if fastest_path[0].x > my_coords.x:
		x_diff = fastest_path[0].x - my_coords.x
	elif fastest_path[0].x < my_coords.x:
		x_diff = my_coords.x - fastest_path[0].x
	else:
		 x_diff = my_coords.x
	if fastest_path[0].y > my_coords.y:
		y_diff = fastest_path[0].y - my_coords.y
	elif fastest_path[0].y < my_coords.y:
		y_diff = my_coords.y - fastest_path[0].y
	else:
		 y_diff = my_coords.y
	
	if (x_diff > -2 || x_diff < 2) && (y_diff > -2 || y_diff < 2):
		executeMoveCommand = true
