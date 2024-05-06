extends Node2D

@onready var Enemy = preload("res://Scenes/Play/Enemy.tscn")
@onready var Player = preload("res://Scenes/Play/Player/Player.tscn")
var _current_spawn = 0

func _ready():
	GameManagerAutoload.play = self
	GameManagerAutoload.foodspawner = $"FoodSpawner"
	GameManagerAutoload.lifesAndPointsGUI = $"LifesAndPoints"
	GameManagerAutoload.sync_gui()
	register_players()
	var level_data = GameManagerAutoload.get_current_level_data()
	setup_level(level_data)

func register_players():
	var players : Array[Player] = []
	for child in get_children():
		if child is Player:
			players.append(child)
	GameManagerAutoload.players = players

func new_ghost(level_data : LevelData):
	var new_enemy = Enemy.instantiate()
	new_enemy.position = Vector2(448 + 2*(randf()-0.5)*56, 500)/3
	new_enemy.Tilemap = $"TileMap"
	new_enemy.chase_temperature = -1/level_data.ghost_intelligence
	new_enemy.movement_speed *= level_data.speed_multiplier
	add_child(new_enemy)

func get_spawn_point(n):
	return %SpawnPoints.get_child(n).position

func spawn_player(player_data, spawn_point_n):
	var pos = get_spawn_point(spawn_point_n)
	var new_player = Player.instantiate()
	new_player.Tilemap = $"TileMap"
	new_player.position = pos
	new_player.color = player_data.color
	new_player.device = player_data.device
	add_child(new_player)
	

func setup_level(level_data : LevelData):
	var tilemap = $"TileMap"
	tilemap.set_layer_modulate(0, level_data.level_color)
	
	var i = 0
	for player_data in level_data.players:
		spawn_player(player_data, i)
		i += 1
	
	await get_tree().create_timer(1.5).timeout
	
	for _j in range(level_data.starting_ghosts):
		new_ghost(level_data)
		await get_tree().create_timer(randf()+0.5).timeout
	
	for _j in range(max(level_data.ghosts - level_data.starting_ghosts, 0)):
		await get_tree().create_timer(level_data.ghost_interval).timeout
		new_ghost(level_data)
