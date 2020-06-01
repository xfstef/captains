extends Node2D

var my_animation
var target_coords
var tween
var camera

func _ready():
	my_animation = get_node("AnimatedSprite")
	target_coords = Vector2(self.position.x, self.position.y)
	tween = get_node("Tween")

func _process(delta):
	if !tween.is_active():
		my_animation.playing = false
		my_animation.frame = 0

func moveTo(x_y):
	x_y.y += 38
	target_coords = x_y

	tween.interpolate_property(self, 'position', self.position, target_coords, 1, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
	tween.start()
	my_animation.playing = true
	
