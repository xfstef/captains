extends ScrollContainer

var vertical_scrollbar
var mouse_controller

func _ready():
	mouse_controller = get_node("/root/AdventureMap/MouseCtrl")
	vertical_scrollbar = get_child(1)
	vertical_scrollbar.connect("mouse_entered", self, "mouseOn")
	vertical_scrollbar.connect("mouse_exited", self, "mouseOff")

func mouseOn():
	mouse_controller.setMouseState(4)

func mouseOff():
	mouse_controller.setMouseState(0)
