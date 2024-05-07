extends PanelContainer

func _ready():
	%Resume.grab_focus()

func resume():
	GameManagerAutoload.unpause_game()
	MusicPlayerAutoload.unpause()
	queue_free()

func _input(event):
	if event.is_action_pressed("Pause"):
		resume()

func _on_resume_pressed():
	resume()


func _on_exit_to_menu_pressed():
	LevelManagerAutoload.transition_to("res://Scenes/Menu/MainMenu/MainMenu.tscn")
	MusicPlayerAutoload.stop_music()


func _on_exit_game_pressed():
	get_tree().quit()
