extends Node2D

var points = 0 : set = _set_points

func collision_with_food(_body):
	points += 10

func _set_points(new_points):
	points = new_points
	$Label.text = str(new_points)
