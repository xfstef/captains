extends Control

var singlePlayerGame = load("res://Scenes/AdventureMap.tscn")
var quitButton

# Called when the node enters the scene tree for the first time.
func _ready():
	quitButton = get_node("MenuPanel/Quit")

func _on_Quit_button_up():
	get_tree().quit()

func _on_SinglePlayer_button_up():
	get_tree().change_scene("res://Scenes/AdventureMap.tscn")

func _on_MapCreator_button_up():
	pass # Replace with function body.
