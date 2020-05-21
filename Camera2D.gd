extends Camera2D

const MOVE_SPEED_H = 48
const MOVE_SPEED_V = 32

func _process(delta):
	print(self.position)
	if Input.is_action_pressed("ui_left"):
		self.position[0] -= MOVE_SPEED_H
	elif Input.is_action_pressed("ui_right"):
		self.position[0] += MOVE_SPEED_H
	elif Input.is_action_pressed("ui_up"):
		self.position[1] -= MOVE_SPEED_V
	elif Input.is_action_pressed("ui_down"):
		self.position[1] += MOVE_SPEED_V
