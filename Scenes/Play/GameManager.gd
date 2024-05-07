extends Node2D

@onready var LevelsData = preload("res://Scenes/Play/Levels/Levels.tres")

var points = 0 : set = _set_points
var lifes = 3 : set = _set_lifes
var max_lifes = 3 : set = _set_max_lifes
var current_level = 0 : set = _set_level
var current_tone = 0
var current_type_of_tone = 1
var half_tone = 1

var TONES = [
	[
		440.,
		587.,
		440.,
		587.,
		783.,
		1044.,
		783.,
		587.,
		783.,
		587.,
		440.,
		587.,
		783.,
		440
	],
	[
		440,
		659,
		440,
		659,
		587,
		659,
		587,
		988,
		587,
		659,
		587,
		659,
		440,
		659,
		587,
		440
	],
	[
		440,
		554,
		440,
		554,
		659,
		554,
		659,
		831,
		659,
		554,
		659,
		554,
		440,
		554,
		659,
		440
	]
]

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
	var sound_player = _body.get_parent().get_node("%PointSound")
	var current_tone_list = TONES[current_type_of_tone]
	sound_player.pitch_scale = current_tone_list[current_tone % len(current_tone_list)]/440./half_tone
	current_tone += 1
	if current_tone == len(current_tone_list):
		current_type_of_tone = randi_range(0, len(TONES) - 1)
		half_tone = 2 if randi_range(0, 1) == 1 else 1
		current_tone = 0
	
	sound_player.play()
	check_if_win()

func _set_points(new_points):
	points = new_points
	if lifesAndPointsGUI and lifesAndPointsGUI != null:
		lifesAndPointsGUI.points = new_points

func _set_level(value):
	current_level = value
	if lifesAndPointsGUI and lifesAndPointsGUI != null:
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

func pause_game():
	var PauseGame = load("res://Scenes/Play/Pause/PauseMenu.tscn")
	var pause_game = PauseGame.instantiate()
	play.add_child(pause_game)
	lifesAndPointsGUI.visible = false
	play.process_mode = Node.PROCESS_MODE_DISABLED

func unpause_game():
	lifesAndPointsGUI.visible = true
	play.process_mode = Node.PROCESS_MODE_INHERIT

func _set_lifes(v):
	lifes = v
	if lifesAndPointsGUI and lifesAndPointsGUI != null:
		lifesAndPointsGUI.current_lifes = v

func _set_max_lifes(v):
	max_lifes = v
	if lifesAndPointsGUI and lifesAndPointsGUI != null:
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
