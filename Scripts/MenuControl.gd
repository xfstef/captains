extends Control

var singlePlayerGame = load("res://Scenes/AdventureMap.tscn")
var quitButton
var slideIn

# Called when the node enters the scene tree for the first time.
func _ready():
	quitButton = get_node("MenuPanel/Quit")
	slideIn = get_node("SlideIn")

func _on_Quit_button_up():
	get_tree().quit()

func _on_SinglePlayer_button_up():
	slideIn.setContent(1)

func _on_MapCreator_button_up():
	slideIn.setContent(3)
