extends Panel

var mouse_controller
var adventure_map
var current_turn = 1

func _ready():
	adventure_map = get_node("/root/AdventureMap")
	mouse_controller = get_node("/root/AdventureMap/MouseCtrl")

func _on_TurnPanel_mouse_entered():
	mouse_controller.setMouseState(4)

func _on_TurnPanel_mouse_exited():
	mouse_controller.setMouseState(0)

func _on_TurnButton_pressed():
	current_turn += 1
	adventure_map.endTurn(current_turn)
