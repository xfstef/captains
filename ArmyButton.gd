extends Button

var my_id = 0
var my_sprite
var adventure_map

func _ready():
	adventure_map = get_node("/root/AdventureMap")

func setID(new_id):
	my_sprite = get_node("portrait")
	my_id = new_id
	my_sprite.frame = my_id

func _on_ArmyButton_pressed():
	adventure_map.armySelected(my_id)
