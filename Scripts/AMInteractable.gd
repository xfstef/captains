extends Node2D

var my_sprite
var adventure_map
var tm_props
var my_coords
var my_animation
var frequency
var still_valid
var visited_by = []

# Called when the node enters the scene tree for the first time.
func _ready():
	my_sprite = get_node("AnimatedSprite")
	adventure_map = get_tree().get_root().get_node("AdventureMap")
	tm_props = get_parent()
	my_coords = tm_props.world_to_map(self.position)

func loadSprite(name):
	if name != null:
		my_animation = load("res://Assets/TileResources/MapObjects/" + name + ".tres")
		my_sprite.set_sprite_frames(my_animation)
		my_sprite.play("Idle", false)
	else:
		my_animation = null
