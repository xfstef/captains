extends Control

var event_title
var event_description
var eAB
var event_action_buttons = []
var h_box_container
var adventure_map
var action_names = []
var action_specs = []

func _ready():
	event_title = get_node("Panel/eventTitle")
	event_description = get_node("Panel/description")
	eAB = get_node("Panel/HBoxContainer/eventActionButton")
	event_action_buttons.append(eAB)
	h_box_container = get_node("Panel/HBoxContainer")
	adventure_map = get_tree().get_root().get_node("AdventureMap")

func setEventTitle(title):
	event_title.text = title

func setEventDescription(description):
	event_description.text = description

func buildEvent(event_actions):
	action_names.clear()
	action_specs.clear()
	for x in range(event_actions.size()):
		if x % 2 == 0:
			action_names.append(event_actions[x])
		else:
			action_specs.append(event_actions[x])
	buildEventActionNames()
	self.visible = true
	adventure_map.mouseCtrl.setMouseState(5)

func buildEventActionNames():
	for x in range(action_names.size()):
		if event_action_buttons.size() < x + 1:
			var new_action_button = eAB.duplicate()
			event_action_buttons.append(new_action_button)
			h_box_container.add_child(event_action_buttons[x])
		event_action_buttons[x].my_id = x
		event_action_buttons[x].text = action_names[x]
		event_action_buttons[x].visible = true

func eventButtonClicked(id):
	if id > -1:
		for x in range(event_action_buttons.size()):
			event_action_buttons[x].visible = false
#		adventure_map.eventActionPressed(id)
		adventure_map.eventCtrl.parseEventAction(action_specs[id], action_names[id], adventure_map.selected_army_instance, self)
	else:
		visible = false
		adventure_map.mouseCtrl.setMouseState(-1)

func showResult(result):
	event_description.text = result
	event_action_buttons[0].text = "Ok"
	event_action_buttons[0].my_id = -1
	event_action_buttons[0].visible = true
