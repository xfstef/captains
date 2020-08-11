extends Node2D

var my_sprite
var adventure_map
var tm_props
var my_coords
var unit_name
var unit_animations
var has_attacked = false
var amount = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	my_sprite = get_node("AnimatedSprite")
	adventure_map = get_tree().get_root().get_node("AdventureMap")
	tm_props = get_parent()
	my_coords = tm_props.world_to_map(self.position)

func loadSprite(name):
	unit_animations = load("res://Assets/TileResources/MapUnits/" + name + ".tres")
	my_sprite.set_sprite_frames(unit_animations)
	my_sprite.play("Idle", false)

func attack():
	has_attacked = true
	my_sprite.play("Attack", false)

func _on_AnimatedSprite_animation_finished():
	if has_attacked == true:
		my_sprite.stop()

func npcWon(remaining_amount):
	if remaining_amount != -1:
		amount = remaining_amount
	has_attacked = false
	my_sprite.play("Idle", false)
