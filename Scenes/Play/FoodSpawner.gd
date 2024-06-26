extends Node2D

@export var Tilemap : TileMap
@onready var Food = preload("res://Scenes/Play/Food.tscn")

var point_points

func get_points_to_spawn(bounds):
	var points = []
	for x in range(bounds.position[0], bounds.end[0]):
		for y in range(bounds.position[0], bounds.end[1]):
			var pos = Vector2i(x, y)
			var data = Tilemap.get_cell_tile_data(0, pos)
			if data and (not data.get_custom_data("spawn_points")):
				continue
			points.append(Tilemap.map_to_local(pos))
	return points

func spawn_foods(points):
	for pos in points:
		var p = Food.instantiate()
		p.position = pos
		add_child(p)

func _ready():
	var bounds = Tilemap.get_used_rect()
	point_points = get_points_to_spawn(bounds)
	spawn_foods(point_points)

func __draw():
	for pos in point_points:
		draw_circle(pos, 2, Color.YELLOW * 0.8)
