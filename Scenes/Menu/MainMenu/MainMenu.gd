extends Node

func _ready():
	%Play.grab_focus()

func _on_play_pressed():
	LevelManagerAutoload.transition_to("res://Scenes/Menu/SelectPlayer/SelectPlayer.tscn")
	GameManagerAutoload.reset_score()


func _on_options_pressed():
	pass


func _on_exit_pressed():
	get_tree().quit()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
