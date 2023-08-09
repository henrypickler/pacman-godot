class_name MoverBase
extends Node2D

@export var Tilemap : TileMap
@onready var Body = $Body
@export var movement_speed = 36
@export var rotate_with_curve = true

enum directions {
	NONE,
	UP,
	DOWN,
	LEFT,
	RIGHT
}

var t = 0
var from_direction = directions.NONE
var to_direction = directions.NONE : set = _set_to_direction
var stopped : bool : get = _is_stopped

var grid_pos : Vector2i
var grid_size : Vector2

var curve : Curve2D
var curve_length : float
const CURVE_TESSELATE_STAGES = 10

signal reached_end_of_path

func opposite_dir(dir):
	match dir:
		directions.NONE:
			return directions.NONE
		directions.UP:
			return directions.DOWN
		directions.DOWN:
			return directions.UP
		directions.LEFT:
			return directions.RIGHT
		directions.RIGHT:
			return directions.LEFT

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

func _is_new_direction_valid(dir):
	var pos = grid_pos + dir_to_vec(dir)
	var data : TileData = Tilemap.get_cell_tile_data(0, pos)
	var is_solid = false
	if data:
		is_solid = data.get_custom_data("solid")
	return not(is_solid)

func _set_to_direction(new_direction):
	to_direction = new_direction
	_update_path()

func _is_stopped():
	if to_direction == directions.NONE and from_direction == directions.NONE:
		return true
	else:
		return false

func set_new_direction():
	if _is_new_direction_valid(to_direction):
		to_direction = to_direction
	else:
		to_direction = directions.NONE

func _end_of_path():
	from_direction = to_direction
	emit_signal("reached_end_of_path")
	set_new_direction()
	if not stopped:
		_update_path()

func _create_curve():
	curve = Curve2D.new()
	curve.add_point(Vector2(0, 0))
	curve.add_point(Vector2(0, 0))
	curve.bake_interval = 0.3

func _ready():
	Body.position = position
	position = Vector2.ZERO
	grid_size = Vector2(Tilemap.tile_set.tile_size)
	grid_pos = get_body_map_position_in_tilemap()
	_create_curve()
	_update_path()

func _process(delta):
	if stopped:
		t = 0
	else:
		t += movement_speed*delta
	
	while t >= curve.get_baked_length() and not stopped:
		t -= curve.get_baked_length()
		grid_pos += dir_to_vec(to_direction)
		_end_of_path()
	
	if not stopped:
		var transf = curve.sample_baked_with_rotation(t)
		Body.position = transf.get_origin()
		if rotate_with_curve:
			Body.rotation = transf.get_rotation() + PI/2
			#var len = curve.get_baked_length()
			#var dt = 0.1
			#var t1 = t
			#var t2 = t + dt
			#if t2 > curve.get_baked_length():
			#	t2 = t1
			#	t1 = t - dt
			#var pt1 = curve.sample(0, t1/len)
			#var pt2 = curve.sample(0, t2/len)
			#Body.rotation = (pt1 - pt2).angle()
