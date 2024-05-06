extends Control
class_name BaseTransition

signal transition_ended
signal transition_create_scene

func end_transition():
	emit_signal("transition_ended")

func create_scene():
	emit_signal("transition_create_scene")
