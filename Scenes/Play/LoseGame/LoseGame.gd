extends Control

@onready var PointsLabel = %PointsLabel

var points = 0

func _ready():
	PointsLabel.text = "Points: " + str(points)
	MusicPlayerAutoload.pause()
	%TryAgain.grab_focus()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_exit_to_menu_pressed():
	LevelManagerAutoload.transition_to("res://Scenes/Menu/MainMenu/MainMenu.tscn")
	MusicPlayerAutoload.stop_music()


func _on_try_again_pressed():
	LevelManagerAutoload.transition_to("res://Scenes/Play/Play.tscn")
	GameManagerAutoload.reset_score()
