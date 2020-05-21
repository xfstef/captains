extends Camera2D

var move_vector

func _process(delta):
	move_vector = Vector2()
	
	if Input.is_action_pressed("ui_left"):
		move_vector.x -= 1
	elif Input.is_action_pressed("ui_right"):
		move_vector.x += 1
	elif Input.is_action_pressed("ui_up"):
		move_vector.y -= 1
	elif Input.is_action_pressed("ui_down"):
		move_vector.y += 1
		
	global_translate(move_vector * 20)
	
