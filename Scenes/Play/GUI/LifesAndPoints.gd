extends HBoxContainer

@export var max_lifes = 3 : set=set_max_lifes
@export var current_lifes = 3 : set=set_current_lifes
@export var points = 0 : set=set_points
@export var current_level = 0 : set=set_level
@export var empty_life_texture : Texture2D
@export var full_life_texture : Texture2D

@onready var Points = %Points
@onready var Lifes = %Lifes
@onready var Level = %Level


func update_GUI():
	for node in Lifes.get_children():
		Lifes.remove_child(node)
	
	for i in range(max_lifes):
		var new_heart = TextureRect.new()
		
		new_heart.texture = full_life_texture if i < current_lifes else empty_life_texture
		Lifes.add_child(new_heart)

func set_current_lifes(lifes):
	current_lifes = lifes
	update_GUI()

func set_max_lifes(lifes):
	max_lifes = lifes
	update_GUI()

func set_points(value):
	points = value
	Points.text = str(points)

func set_level(value):
	current_level = value
	Level.text = str(current_level)
