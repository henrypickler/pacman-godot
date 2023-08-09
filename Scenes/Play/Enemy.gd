extends MoverBase

func _ready():
	super._ready()
	_end_of_path()
	

func _get_available_directions():
	var valid_dirs = []
	for dir in range(1, 5):
		if dir == opposite_dir(to_direction):
			continue
		if _is_new_direction_valid(dir):
			valid_dirs.append(dir)
	return valid_dirs

func set_new_direction():
	var valid_dirs = _get_available_directions()
	if len(valid_dirs) == 0:
		to_direction = opposite_dir(to_direction)
		return 
	var new_dir_idx = randi_range(0, len(valid_dirs)-1)
	to_direction = valid_dirs[new_dir_idx]
