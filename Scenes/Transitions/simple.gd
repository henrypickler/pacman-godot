extends BaseTransition

enum {GROW, MOVE, END}

var stage = GROW
var curr_size = 0
var pos = 0
var final_size = 1500
var final_pos = 1500
var transition_speed = 3000

func _process(delta):
	if stage == GROW:
		curr_size += transition_speed*delta
		if curr_size >= final_size:
			stage = MOVE
			create_scene()
	elif stage == MOVE:
		pos += transition_speed*delta
		if pos >= final_pos:
			end_transition()
			stage = END
	queue_redraw()
		
func _draw():
	draw_rect(Rect2(Vector2(pos, -1000), Vector2(curr_size, 2000)), Color.WHITE)
