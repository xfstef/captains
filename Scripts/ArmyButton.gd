extends Button

var my_id = 0
var my_sprite
var adventure_map
var mouse_controller

func _ready():
	adventure_map = get_node("/root/AdventureMap")
	mouse_controller = get_node("../../../MouseCtrl")

func setID(new_id):
	my_sprite = get_node("portrait")
	my_id = new_id
	my_sprite.frame = my_id

func _on_ArmyButton_pressed():
	if mouse_controller.pointerState == 5:
		return
	adventure_map.armySelected(my_id)

func _on_ArmyButton_mouse_entered():
	mouse_controller.setMouseState(4)

func _on_ArmyButton_mouse_exited():
	mouse_controller.setMouseState(0)
