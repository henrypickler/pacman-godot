extends Node2D

@onready var LevelsData = preload("res://Scenes/Play/Levels/Levels.tres")

var points = 0 : set = _set_points
var lifes = 3 : set = _set_lifes
var max_lifes = 3 : set = _set_max_lifes
var current_level = 0 : set = _set_level

var play
var foodspawner
var players : Array[Player]
var player_data
var lifesAndPointsGUI

func reset_score():
	points = 0
	max_lifes = 3
	lifes = 3
	current_level = 0

func sync_gui():
	points = points
	max_lifes = max_lifes
	lifes = lifes
	current_level = current_level

func next_level():
	lifes = min(max_lifes, lifes + 1)
	current_level += 1

func check_if_win():
	# The current eaten food still exists
	var count = 1
	for child in foodspawner.get_children():
		if count == 0:
			return
		if child is Food:
			count -= 1
	
	win_game()

func collision_with_food(_body):
	points += 10
	check_if_win()

func _set_points(new_points):
	points = new_points
	if lifesAndPointsGUI:
		lifesAndPointsGUI.points = new_points

func _set_level(value):
	current_level = value
	if lifesAndPointsGUI:
		lifesAndPointsGUI.current_level = current_level + 1

func win_game():
	var YouWin = load("res://Scenes/Play/YouWin/YouWin.tscn")
	var you_win = YouWin.instantiate()
	points += 250*(lifes-1)
	you_win.points = points
	play.add_child(you_win)
	play.process_mode = Node.PROCESS_MODE_DISABLED
	lifesAndPointsGUI = false

func lose_game():
	var LoseGame = load("res://Scenes/Play/LoseGame/LoseGame.tscn")
	var lose_game = LoseGame.instantiate()
	lose_game.points = points
	play.add_child(lose_game)
	play.process_mode = Node.PROCESS_MODE_DISABLED
	lifesAndPointsGUI = false

func _set_lifes(v):
	lifes = v
	if lifesAndPointsGUI:
		lifesAndPointsGUI.current_lifes = v

func _set_max_lifes(v):
	max_lifes = v
	if lifesAndPointsGUI:
		lifesAndPointsGUI.max_lifes = v

func player_collided(player : Player):
	if player.is_invincible:
		return
	do_damage(player)

func do_damage(player : Player):
	lifes -= 1
	points -= 500
	player.took_damage()
	if lifes <= 0:
		lose_game()

func get_current_level_data():
	var current_level = GameManagerAutoload.current_level
	var total_levels = len(LevelsData.levels)
	var level_data = LevelsData.levels[current_level % total_levels]
	level_data.speed_multiplier = 1 + 0.125*floor(current_level / total_levels)
	level_data.players = player_data
	return level_data

#func _input(event):
#	if event.is_action_pressed("ui_cancel"):
#		LevelManagerAutoload.transition_to("res://Scenes/Menu/MainMenu/MainMenu.tscn")
