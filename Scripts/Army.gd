extends Node2D

var my_animation
var move_coords
var selected_coords
var my_coords
var tween
var camera
var travel_type = 0
var fastest_path
var adventure_map

func _ready():
	my_animation = get_node("AnimatedSprite")
	move_coords = Vector2(self.position.x, self.position.y)
	tween = get_node("Tween")
	# TODO: Add a means of loading what type of travel this army does: Land march, Sailing, Flying, Tunneling.
	travel_type = 0
	adventure_map = get_node("/root/AdventureMap")

func _process(delta):
	if !tween.is_active() && my_animation.playing:
		my_animation.playing = false
		my_animation.frame = 0
		my_coords = adventure_map.propsTileMap.world_to_map(self.position)

func moveTo(x_y):
	x_y.y += 37
	move_coords = x_y

	tween.interpolate_property(self, 'position', self.position, move_coords, 1, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()
	my_animation.playing = true
	
func changeTravelType(new_travel_type):
	travel_type = new_travel_type

func calculateFastestPath(target_tile):
	var shortest_path_found = 1000
	
