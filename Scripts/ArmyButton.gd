extends Button

var my_army_id = 0
var my_frame_id = 0
var my_player_id = 0
var my_sprite
var adventure_map
var mouse_controller

func _ready():
	adventure_map = get_node("/root/AdventureMap")
	mouse_controller = get_node("/root/AdventureMap/MouseCtrl")

func setFrameID(new_id):
	my_sprite = get_node("portrait")
	my_frame_id = new_id
	my_sprite.frame = my_frame_id

func _on_ArmyButton_pressed():
	if mouse_controller.pointerState == 5:
		return
	adventure_map.armySelected(my_army_id)
