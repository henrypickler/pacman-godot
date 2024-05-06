class_name Player
extends MoverBase

var next_direction = directions.NONE
const INVENCIBILITY_TIME = 2
var is_invincible = false : set=set_invincibility

var device = 1
var color : Color = Color.YELLOW : set = set_color

var _bumped = false
var stunned = false

func _ready():
	super._ready()
	_end_of_path()
	color = color

func took_damage():
	is_invincible = true
	$Timer.start(INVENCIBILITY_TIME)

func end_invincibility():
	is_invincible = false

func set_invincibility(v):
	if v == true:
		$AnimationPlayer.play("damage")
	else:
		$AnimationPlayer.play("none")
	is_invincible = v

func set_color(new_color):
	color = new_color
	%PlayerImage.modulate = color
	

func set_new_direction():
	if _is_new_direction_valid(next_direction):
		to_direction = next_direction
	elif _is_new_direction_valid(to_direction):
		to_direction = to_direction
	else:
		to_direction = directions.NONE
		
func _process(delta):
	super._process(delta)
	%Eyeballs.position = Vector2(dir_to_vec(next_direction)).normalized().rotated(-%Body.rotation)

func _input(event):
	if stunned:
		return
	
	if event.device != device:
		return
	var dir
	if event.is_action_pressed("Move up") and from_direction != directions.DOWN:
		dir = directions.UP
	elif event.is_action_pressed("Move right") and from_direction != directions.LEFT:
		dir = directions.RIGHT
	elif event.is_action_pressed("Move down") and from_direction != directions.UP:
		dir = directions.DOWN
	elif event.is_action_pressed("Move left") and from_direction != directions.RIGHT:
		dir = directions.LEFT
	
	if dir:
		next_direction = dir
		if _is_new_direction_valid(dir):
			if stopped:
				to_direction = dir
			else:
				if t/curve.get_baked_length() < 0.35:
					to_direction = next_direction


func _player_bump(area):
	var other = area.get_parent().get_parent()
	var facing = Vector2(-1, 0).rotated(Body.rotation)
	var angle_to = (other.Body.position - Body.position).angle_to(facing)
	if abs(angle_to) < PI/4:
		to_direction = directions.NONE
		from_direction = directions.NONE
		stunned = true
		$Node2D/StunAnimation.play("start")
		$Node2D/StunAnimation.visible = true
		$StunTimer.start(1.0)
		Body.rotation = PI - Body.rotation


func end_stun():
	stunned = false
	$Node2D/StunAnimation.visible = false
