extends Node2D

var my_animation
var target_coords
var tween
var camera
var travel_type = 0

func _ready():
	my_animation = get_node("AnimatedSprite")
	target_coords = Vector2(self.position.x, self.position.y)
	tween = get_node("Tween")
	# TODO: Add a means of loading what type of travel this army does: Land march, Sailing, Flying, Tunneling.
	travel_type = 0

func _process(delta):
	if !tween.is_active():
		my_animation.playing = false
		my_animation.frame = 0

func moveTo(x_y):
	x_y.y += 37
	target_coords = x_y

	tween.interpolate_property(self, 'position', self.position, target_coords, 1, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()
	my_animation.playing = true
	
func changeTravelTyep(new_travel_type):
	travel_type = new_travel_type
