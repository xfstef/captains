extends Node2D

var my_flag = load("res://Scenes/PlayerFlag.tscn")
var my_flag_instance
var my_flag_i_sprite
var my_sprite
var adventure_map
var tm_props
var my_coords
var my_animation
var frequency
var still_valid
var description
var choices
var visited_by = []
var cell_id
var interactable_cell
var my_player_id
var capturable = false
var flag_offset = Vector2(0, 0)
var disabled = false

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

func loadFlag(default_flag):
	my_flag_instance = my_flag.instance()
	add_child(my_flag_instance)
	my_flag_instance.position = flag_offset
	my_flag_i_sprite = my_flag_instance.get_node("AnimatedSprite")
	my_flag_i_sprite.frame = default_flag
