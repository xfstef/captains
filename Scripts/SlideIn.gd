extends Panel

# List of options for slide in visibility and objects:
# None - 0
# Single Player - 1
# Multi Player - 2
# Map Creator - 3
# Options - 4
var currentlyShowing = 0
# Values for animation
# No movement - 0
# Move in - 1
# Move out - 2
var animateMovement = 0

func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if animateMovement == 1:
		self.anchor_left += .05
		self.anchor_right += .05
		if self.anchor_left > 0:
			animateMovement = 0
	elif animateMovement == 2:
		self.anchor_left -= .05
		self.anchor_right -= .05
		if self.anchor_right < 0:
			animateMovement = 0
			currentlyShowing = 0

func setContent(new_value):
	if currentlyShowing == 0:
		animateMovement = 1
	elif currentlyShowing == new_value:
		animateMovement = 2
	currentlyShowing = new_value
