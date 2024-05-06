extends Control

var levelManager : LevelManager
@onready var PointsLabel = %PointsLabel

var points = 0

func _ready():
	PointsLabel.text = "Points: " + str(points)
	%NextLevel.grab_focus()

func _on_next_level_pressed():
	LevelManagerAutoload.transition_to("res://Scenes/Play/Play.tscn")
	GameManagerAutoload.next_level()


func _on_exit_to_menu_pressed():
	LevelManagerAutoload.transition_to("res://Scenes/Menu/MainMenu/MainMenu.tscn")
