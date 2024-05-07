extends Node2D

@onready var Enemy = preload("res://Scenes/Play/Enemy/Enemy.tscn")

var level_data
var Tilemap

func _on_animation_finished():
	var new_enemy = Enemy.instantiate()
	new_enemy.Tilemap = Tilemap
	new_enemy.chase_temperature = -1/level_data.ghost_intelligence
	new_enemy.movement_speed *= level_data.speed_multiplier
	new_enemy.position = position
	get_parent().add_child(new_enemy)
