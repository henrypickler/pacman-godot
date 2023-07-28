extends Node2D

@export var Tilemap : TileMap
@onready var Body = $Body
@onready var Path = $Path2D

var t = 0
@export var movement_speed = 36

enum directions {
	NONE,
	UP,
	DOWN,
	LEFT,
	RIGHT
}
var from_direction = directions.NONE
var to_direction = directions.NONE
var new_direction = directions.NONE

var grid_pos : Vector2i
var grid_size : Vector2

const CURVE_TESSELATE_STAGES = 10
var curve : Curve2D
var curve_length : float
var stopped : bool

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
	
	curve.set_point_position(0, from)
	curve.set_point_out(0, from_dir_vec*grid_size/1.5)
	curve.set_point_in(0, to_dir_vec*grid_size/1.5)
	curve.set_point_position(1, to)
	
	print("from ", from_direction, " - ", from, " to ", to_direction, " - ", to)

func _is_new_direction_valid(dir):
	var pos = grid_pos + dir_to_vec(dir)
	var data : TileData = Tilemap.get_cell_tile_data(0, pos)
	var is_solid = false
	if data:
		is_solid = data.get_custom_data("solid")
	return not(is_solid)

func _update_direction():
	from_direction = to_direction
	if _is_new_direction_valid(new_direction):
		to_direction = new_direction
	else:
		to_direction = directions.NONE
	if to_direction == directions.NONE and from_direction == directions.NONE:
		stopped = true
	else:
		stopped = false
		_update_path()

func _ready():
	Body.position = position
	position = Vector2.ZERO
	grid_size = Vector2(Tilemap.tile_set.tile_size)
	grid_pos = get_body_map_position_in_tilemap()
	curve = Path.curve
	_update_path()

func _process(delta):
	if stopped:
		t = 0
		if new_direction != directions.NONE:
			_update_direction()
	else:
		t += movement_speed*delta
	
	while t >= curve.get_baked_length() and not stopped:
		print("FINISHED ", t)
		t -= curve.get_baked_length()
		grid_pos += dir_to_vec(to_direction)
		_update_direction()
	
	if not stopped:
		var transf = curve.sample_baked_with_rotation(t)
		Body.position = transf.get_origin()
		Body.rotation = transf.get_rotation() + PI/2

func _input(event):
	var dir
	if event.is_action_pressed("ui_up") and from_direction != directions.DOWN:
		dir = directions.UP
	elif event.is_action_pressed("ui_right") and from_direction != directions.LEFT:
		dir = directions.RIGHT
	elif event.is_action_pressed("ui_down") and from_direction != directions.UP:
		dir = directions.DOWN
	elif event.is_action_pressed("ui_left") and from_direction != directions.RIGHT:
		dir = directions.LEFT
	
	if dir:
		print(dir, " - ", _is_new_direction_valid(dir))
		if _is_new_direction_valid(dir):
			new_direction = dir
			if t/curve.get_baked_length() < 0.6 and not stopped:
				to_direction = dir
				_update_path()
