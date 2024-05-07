extends AudioStreamPlayer

@export var volume_offset = 0.0 : set = set_volume_offset

func _ready():
	volume_db = GlobalOptionsAutoload.options["music_volume_db"]
	print(volume_db)

func set_volume_offset(value):
	volume_db = volume_db + value - volume_offset
	volume_offset = value

func start():
	$AnimationPlayer.queue("start")

func stop_music():
	$AnimationPlayer.queue("stop")

func pause():
	$AnimationPlayer.queue("pause")

func unpause():
	$AnimationPlayer.queue("unpause")
