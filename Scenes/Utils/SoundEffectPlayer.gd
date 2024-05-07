extends AudioStreamPlayer
class_name SoundEffectPlayer

var _previous_config = 0

func _ready():
	update_config()

func update_config():
	volume_db = volume_db + GlobalOptionsAutoload.options["sound_effects_volume_db"] - _previous_config
	_previous_config = GlobalOptionsAutoload.options["sound_effects_volume_db"]
