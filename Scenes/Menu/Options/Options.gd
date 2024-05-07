extends VBoxContainer

var sound_effect_volume = 0 : set = set_sound_effect_volume
var music_volume = 0 : set = set_music_volume


func _ready():
	sound_effect_volume = GlobalOptionsAutoload.options["sound_effects_volume_db"]
	music_volume = GlobalOptionsAutoload.options["music_volume_db"]
	%SoundEffectVolumeSlider.connect("value_changed", _sound_effect_volume_changed)
	%MusicVolumeSlider.connect("value_changed", _on_music_volume_changed)
	%BackButton.grab_focus()


func set_sound_effect_volume(volume):
	%SoundEffectVolumeSlider.value = volume
	sound_effect_volume = volume


func set_music_volume(volume):
	%MusicVolumeSlider.value = volume
	MusicPlayerAutoload.volume_db = volume
	MusicPlayerAutoload.volume_offset = 0
	music_volume = volume

func _sound_effect_volume_changed(value_changed):
	sound_effect_volume = %SoundEffectVolumeSlider.value
	%SoundEffectPlayer.volume_db = sound_effect_volume
	%SoundEffectPlayer.play()


func _on_music_volume_changed(value_changed):
	music_volume = %MusicVolumeSlider.value
	%SoundEffectPlayer.volume_db = music_volume
	%SoundEffectPlayer.play()

func back():
	GlobalOptionsAutoload.options["sound_effects_volume_db"] = sound_effect_volume
	GlobalOptionsAutoload.options["music_volume_db"] = music_volume
	GlobalOptionsAutoload.sync_option_file()
	LevelManagerAutoload.transition_to("res://Scenes/Menu/MainMenu/MainMenu.tscn")

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		LevelManagerAutoload.transition_to("res://Scenes/Menu/MainMenu/MainMenu.tscn")
