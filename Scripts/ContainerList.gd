extends Container

var current_player = 0
var current_army = 0

func _ready():
	pass # Replace with function body.

func switchPlayer(new_player):
	current_player = new_player
	for child in get_children():
		if child.my_player_id != current_player:
			child.visible = false
		else:
			child.visible = true

func switchArmy(new_army):
	current_army = new_army
	for army in get_children():
		if army.my_army_id != current_army:
			army.visible = false
		elif army.my_player_id == current_player:
			army.visible = true
