class_name Ghost
extends MoverBase

@onready var EyesOffset = $Body/Eyes/Offset
@export var chase_temperature = -1.2

signal player_collided(player : Player)

func _ready():
	super._ready()
	_end_of_path()
	connect("player_collided", GameManagerAutoload.player_collided)

func _get_available_directions():
	var valid_dirs = []
	for dir in range(1, 5):
		if dir == opposite_dir(to_direction):
			continue
		if _is_new_direction_valid(dir):
			valid_dirs.append(dir)
	return valid_dirs

func _random_new_dir(valid_dirs):
	var new_dir_idx = randi_range(0, len(valid_dirs)-1)
	return valid_dirs[new_dir_idx]

func _apply_exp_temp(vec, temp):
	var new_vec = []
	for i in range(len(vec)):
		new_vec.append(exp(vec[i]/temp))
	return new_vec
	

func _sum(vec):
	var sum = 0
	for i in range(len(vec)):
		sum += vec[i]
	return sum

func _softmax(vec, temp):
	vec = _apply_exp_temp(vec, temp)
	var sum = _sum(vec)
	for i in range(len(vec)):
		vec[i] = vec[i]/sum
	return vec

func _player_dist_at_pos(pos):
	var min_distance = INF
	for player in GameManagerAutoload.players:
		min_distance = min(Tilemap.get_distance_between_points(pos, player.grid_pos), min_distance)
	return min_distance


func _new_dir_weighed_by_distance(valid_dirs):
	var dists = []
	for dir in valid_dirs:
		var pos = get_grid_position_at_dir(dir)
		var dist = _player_dist_at_pos(pos)
		dists.append(dist)
	var softmax_dists = _softmax(dists, chase_temperature)
	
	var selected_weight = randf()
	for i in range(len(valid_dirs)):
		selected_weight -= softmax_dists[i]
		if selected_weight <= 0:
			return valid_dirs[i]
	return _random_new_dir(valid_dirs)
	

func set_new_direction():
	var valid_dirs = _get_available_directions()
	if len(valid_dirs) == 0:
		to_direction = opposite_dir(to_direction)
		return 
	to_direction = _new_dir_weighed_by_distance(valid_dirs)

func _process(delta):
	super._process(delta)
	EyesOffset.position = velocity.normalized()


func player_collision(body):
	emit_signal("player_collided", body.get_parent())
