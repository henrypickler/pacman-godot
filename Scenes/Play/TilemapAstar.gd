extends TileMap

var positions = {}
var astar : AStar2D
var current_astar_id = 0

func _init():
	astar = AStar2D.new()
	_init_astar()

func get_solidness(pos : Vector2i) -> bool:
	var data : TileData = get_cell_tile_data(0, pos)
	var is_solid = false
	if data and data.get_custom_data("solid"):
		is_solid = true
	return is_solid

func _loop_register(bounds : Rect2i) -> void:
	for x in range(bounds.position.x, bounds.end.x):
		for y in range(bounds.position.y, bounds.end.y):
			var pos = Vector2i(x, y)
			if get_solidness(pos):
				continue
			positions[pos] = current_astar_id
			astar.add_point(current_astar_id, pos)
			current_astar_id += 1
	
	for x in range(bounds.position.x, bounds.end.x-1):
		for y in range(bounds.position.y, bounds.end.y-1):
			var pos = Vector2i(x, y)
			if get_solidness(pos):
				continue
			var right_pos = pos + Vector2i(1, 0)
			var down_pos = pos + Vector2i(0, 1)
			if not get_solidness(right_pos):
				astar.connect_points(positions[pos], positions[right_pos])
			if not get_solidness(down_pos):
				astar.connect_points(positions[pos], positions[down_pos])

func _init_astar():
	var bounds = get_used_rect()
	_loop_register(bounds)

func get_distance_between_points(p1, p2):
	var p1_id = astar.get_closest_point(p1)
	var p2_id = astar.get_closest_point(p2)
	var path = astar.get_point_path(p1_id, p2_id)
	var dist = INF
	for i in range(len(path)-1):
		if i == 0:
			dist = 0
		dist += path[i].distance_to(path[i+1])
	return dist
