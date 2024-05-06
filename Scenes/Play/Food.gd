extends Area2D
class_name Food

func _ready():
	connect("body_entered", GameManagerAutoload.collision_with_food)

func _on_body_entered(body):
	queue_free()
	disconnect("body_entered", GameManagerAutoload.collision_with_food)
