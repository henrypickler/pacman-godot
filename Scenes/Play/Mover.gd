extends Node2D

@export var Tilemap : TileMap
@onready var Body = $Body
@onready var Path = $Path2D

var t = 0
@export var movement_speed = 15

enum directions {
	NONE,
	UP,
	DOWN,
	LEFT,
	RIGHT
}
var from_direction = directions.NONE
var to_direction = directions.RIGHT
var new_direction = directions.RIGHT

var grid_pos : Vector2i
var grid_size : Vector2

const CURVE_TESSELATE_STAGES = 10
var curve : PackedVector2Array
var curve_length : float

func dir_to_vec(dir) -> Vector2i:
	match dir:
		directions.NONE:
			return Vector2i.ZERO
		directions.UP:
			return Vector2i.UP
		directions.DOWN:
			return Vector2i.DOWN
		directions.LEFT:
			return Vector2i.LEFT
		directions.RIGHT:
			return Vector2i.RIGHT
		_:
			return Vector2i.ZERO

func get_new_direction():
	return new_direction

func get_body_map_position_in_tilemap() -> Vector2i:
	return Tilemap.local_to_map(Tilemap.to_local(Body.global_position))

func get_global_body_pos_from_map_pos(map_pos : Vector2i) -> Vector2:
	return Tilemap.to_global(Tilemap.map_to_local(map_pos))

func _update_path():
	var from_dir_vec = Vector2(dir_to_vec(from_direction))
	var grid_pos_vec = get_global_body_pos_from_map_pos(grid_pos)
	var from_dt = - Tilemap.to_global(from_dir_vec)*grid_size/2
	var from = to_local(grid_pos_vec + from_dt)
	var to_dir_vec = Vector2(dir_to_vec(to_direction))
	var to_dt = Tilemap.to_global(to_dir_vec)*grid_size/2
	var to = to_local(grid_pos_vec + to_dt)
	print(grid_pos, " from ", from_direction, " to ", to_direction, " ", grid_pos_vec, from, to)
	Path.curve.set_point_position(0, from)
	Path.curve.set_point_out(0, from_dir_vec*grid_size/2)
	Path.curve.set_point_in(0, to_dir_vec*grid_size/2)
	Path.curve.set_point_position(1, to)
	_update_curve()

func _get_current_curve_position(t : float):
	var N = curve.size()
	var i = int(floor(N*t))
	return curve[i]

func _calculate_curve_length():
	var length = 0
	for i in range(curve.size() - 1):
		length += curve[i].distance_to(curve[i+1])
	return length

func _get_curve_angle_at(t):
	var tf = t + 0.005
	if tf > 1:
		tf = t
		t -= 0.005
	var p1 = _get_current_curve_position(t)
	var p2 = _get_current_curve_position(tf)
	return (p2 - p1).angle()

func _update_curve():
	curve = Path.curve.tessellate_even_length(CURVE_TESSELATE_STAGES, 0.05)
	curve_length = _calculate_curve_length()
	
func _draw():
	var px1 = curve[0]
	for i in range(curve.size() - 1):
		var px2 = curve[i+1]
		draw_line(px1, px2, Color.GRAY, 3.0)
		px1 = px2

func _ready():
	Body.position = position
	position = Vector2.ZERO
	grid_size = Vector2(Tilemap.tile_set.tile_size)
	grid_pos = get_body_map_position_in_tilemap()
	_update_path()

func _process(delta):
	queue_redraw()
	if to_direction == directions.NONE:
		return
	var t_speed = curve_length/movement_speed
	t += delta/t_speed
	
	while t >= 1:
		t -= 1
		grid_pos += dir_to_vec(to_direction)
		from_direction = to_direction
		to_direction = get_new_direction()
		_update_path()
	var pos1 = Body.position
	Body.position = _get_current_curve_position(t)
	var pos2 = Body.position
	print((pos2 - pos1).length())
	Body.rotation = _get_curve_angle_at(t)

func _input(event):
	if event.is_action_pressed("ui_up") and to_direction != directions.DOWN:
		new_direction = directions.UP
	elif event.is_action_pressed("ui_right") and to_direction != directions.LEFT:
		new_direction = directions.RIGHT
	elif event.is_action_pressed("ui_down") and to_direction != directions.UP:
		new_direction = directions.DOWN
	elif event.is_action_pressed("ui_left") and to_direction != directions.RIGHT:
		new_direction = directions.LEFT
