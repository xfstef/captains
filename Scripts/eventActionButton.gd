extends Button

var my_id
var adventure_event

func _on_eventActionButton_pressed():
	adventure_event = get_node("/root/AdventureMap/UI/AdventureEvent")
	adventure_event.eventButtonClicked(my_id)
