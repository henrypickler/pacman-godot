extends Node

var options = {
	"music_volume_db": 0,
	"sound_effects_volume_db": -5,
}
var _config : ConfigFile

const PATH_TO_OPTIONS = "res://options.ini"

func _ready():
	_config = ConfigFile.new()
	var err = _config.load(PATH_TO_OPTIONS)
	if err != OK:
		_dict_to_config()
	else:
		_config_to_options()
	sync_option_file()

func _config_to_options():
	for option in options:
		options[option] = _config.get_value("options", option, options[option])
		print("Loading option ", option, " with value ", options[option])

func _dict_to_config():
	for option in options:
		_config.set_value("options", option, options[option])

func sync_option_file():
	_dict_to_config()
	_config.save(PATH_TO_OPTIONS)
