extends Control

var date_label
var event_label
var confirm
var adventure_map

func _ready():
	date_label = get_node("Panel/dateLabel")
	event_label = get_node("Panel/eventLabel")
	confirm = get_node("Panel/confirm")
	adventure_map = get_tree().get_root().get_node("AdventureMap")

func setNewDay(new_date, new_event):
	adventure_map.mouseCtrl.setMouseState(5)
	date_label.text = new_date
	if new_event != null:
		event_label.text = new_event
	else:
		event_label.text = "Nothing in particular is happening today."
	visible = true	

func _on_confirm_pressed():
	visible = false
	adventure_map.mouseCtrl.setMouseState(-1)
