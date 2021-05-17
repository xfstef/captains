extends Control

var singlePlayerGame = load("res://Scenes/AdventureMap.tscn")
var mapCreator = load("res://Scenes/MapCreator.tscn")
var quitButton
var slideInSP
var slideInMC
var customWidth
var customHeight
var _params

# Called when the node enters the scene tree for the first time.
func _ready():
	quitButton = get_node("MenuPanel/Quit")
	slideInSP = get_node("SlideInSP")
	slideInMC = get_node("SlideInMC")
	customWidth = get_node("SlideInMC/TabContainer/New Map/width")
	customHeight = get_node("SlideInMC/TabContainer/New Map/height")

func _on_Quit_button_up():
	get_tree().quit()

func _on_SinglePlayer_button_up():
	if slideInSP.isShowing:
		slideInSP.setContent(false)
	else:
		slideInSP.setContent(true)
	if slideInMC.isShowing:
		slideInMC.setContent(false)

func _on_MapCreator_button_up():
	if slideInMC.isShowing:
		slideInMC.setContent(false)
	else:
		slideInMC.setContent(true)
	if slideInSP.isShowing:
		slideInSP.setContent(false)

func _on_size_button_up(width, height):
	if width > 0 && height > 0:
		var new_scene = mapCreator.instance()
		new_scene.width = width
		new_scene.height = height
		get_tree().get_root().add_child(new_scene)
		get_node("/root/MainMenu").free()
