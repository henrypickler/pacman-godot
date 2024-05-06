extends Node2D
class_name LevelManager

#@onready var PlayScene = preload("res://Scenes/Play/Play.tscn")
@onready var TransitionScene = preload("res://Scenes/Transitions/simple.tscn")

var current_scene = false
var current_transition = false

func _ready():
	var root = get_tree().root
	current_scene = root.get_child(root.get_child_count() - 1)

func transition_to(scene_path):
	call_deferred("_transition_to", scene_path)

func _transition_to(scene_path):
	if current_transition:
		return
	current_transition = TransitionScene.instantiate()
	current_transition.rotation = randf_range(0, PI/2)
	current_transition.top_level = true
	add_child(current_transition)
	current_transition.connect(
		"transition_create_scene",
		func():
			var scene = load(scene_path)
			if current_scene:
				current_scene.free()
				current_scene = false
			current_scene = scene.instantiate()
			current_scene.process_mode = Node.PROCESS_MODE_DISABLED
			get_tree().root.add_child(current_scene)
			get_tree().current_scene = current_scene
	)
	current_transition.connect(
		"transition_ended",
		func():
			current_transition.queue_free()
			current_transition = false
			current_scene.process_mode = Node.PROCESS_MODE_INHERIT
	)
