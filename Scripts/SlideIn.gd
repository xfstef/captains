extends Panel

var isShowing = false
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

func setContent(show):
	if show:
		animateMovement = 1
	else:
		animateMovement = 2
	isShowing = show

