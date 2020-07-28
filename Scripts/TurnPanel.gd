extends Panel

var mouse_controller
var adventure_map
var current_turn = 1
var current_day = 1
var current_week = 1
var current_month = 1
var turn_label
var turn_label_string

func _ready():
	adventure_map = get_node("/root/AdventureMap")
	mouse_controller = get_node("/root/AdventureMap/MouseCtrl")
	turn_label = get_node("TurnLabel")
	turn_label_string = "Day " + String(current_day) + ", Week " + String(current_week) + ", Month " + String(current_month)
	turn_label.text = turn_label_string

func _on_TurnPanel_mouse_entered():
	mouse_controller.setMouseState(4)

func _on_TurnPanel_mouse_exited():
	mouse_controller.setMouseState(0)

func _on_TurnButton_pressed():
	if mouse_controller.pointerState == 5:
		return
	current_turn += 1
	current_day += 1
	if current_day > 7:
		current_day = 1
		current_week += 1
		if current_week > 4:
			current_week = 1
			current_month += 1
	
	adventure_map.endTurn(current_turn)

func setTurnLabel():
	turn_label_string = "Day " + String(current_day) + ", Week " + String(current_week) + ", Month " + String(current_month)
	turn_label.text = turn_label_string
