class_name Player
extends MoverBase

var next_direction = directions.NONE

func set_new_direction():
	print("Next dir ", next_direction)
	if _is_new_direction_valid(next_direction):
		to_direction = next_direction
	elif _is_new_direction_valid(to_direction):
		to_direction = to_direction
	else:
		to_direction = directions.NONE

func _input(event):
	var dir
	if event.is_action_pressed("ui_up") and from_direction != directions.DOWN:
		dir = directions.UP
	elif event.is_action_pressed("ui_right") and from_direction != directions.LEFT:
		dir = directions.RIGHT
	elif event.is_action_pressed("ui_down") and from_direction != directions.UP:
		dir = directions.DOWN
	elif event.is_action_pressed("ui_left") and from_direction != directions.RIGHT:
		dir = directions.LEFT
	
	if dir:
		print(dir, " - ", _is_new_direction_valid(dir), " stopped ", stopped)
		next_direction = dir
		if _is_new_direction_valid(dir):
			if stopped:
				to_direction = dir
			else:
				if t/curve.get_baked_length() < 0.35:
					to_direction = next_direction
