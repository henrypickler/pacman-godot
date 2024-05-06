extends VBoxContainer

@export var player = 1
var device = null : set = set_device
var focus : Control = null : set = set_focus
var current_color : set = set_current_color

enum PLAYER_CARD_STATES {INACTIVE, ACTIVE, READY}

var state : set = set_state

signal deactivate(card)
signal player_ready

const PLAYER_COLOR_LIST = [
	Color.YELLOW,
	Color.BLUE,
	Color.WEB_GREEN,
	Color.ORANGE_RED,
	Color.ORANGE,
	Color.HOT_PINK,
	Color.CYAN,
	Color.PURPLE,
	Color.LIME_GREEN,
	Color.TEAL,
	Color.MAGENTA,
	Color.LIGHT_GRAY,
	Color.ROYAL_BLUE,
	Color.DARK_ORANGE,
	Color.CADET_BLUE,
	Color.GREEN_YELLOW
]

func _ready():
	%Title.text = "Player " + str(player)
	current_color = player - 1
	state = PLAYER_CARD_STATES.INACTIVE
	
	for child in get_children():
		if child.get("focus_mode"):
			child.focus_mode = FOCUS_NONE

func _draw():
	if state == PLAYER_CARD_STATES.ACTIVE and focus != null:
		print(focus)
		var pos = focus.global_position - global_position
		var s = focus.size
		draw_rect(Rect2(pos, s), Color.BLUE, false, 5)

func set_device(new_device):
	device = new_device
	print(device)
	if device != null:
		state = PLAYER_CARD_STATES.ACTIVE
		focus = get_node("Active/VBoxContainer/Ready")
	else:
		state = PLAYER_CARD_STATES.INACTIVE
		focus = null

func set_state(val):
	state = val
	match state:
		PLAYER_CARD_STATES.INACTIVE:
			%Active.visible = false
			%Inactive.visible = true
		PLAYER_CARD_STATES.ACTIVE:
			%Active.visible = true
			%Inactive.visible = false
		PLAYER_CARD_STATES.READY:
			emit_signal("player_ready")

func is_ready():
	return state == PLAYER_CARD_STATES.READY

func is_active_and_not_ready():
	return state == PLAYER_CARD_STATES.ACTIVE

func set_focus(new_focus):
	focus = new_focus
	queue_redraw()

func click_on_control(control):
	var click_event = InputEventMouseButton.new()
	click_event.position = control.global_position
	click_event.pressed = true
	click_event.button_index = MOUSE_BUTTON_LEFT
	Input.parse_input_event(click_event)
	
	await get_tree().process_frame
	
	click_event.pressed = false
	Input.parse_input_event(click_event)
	
	await get_tree().process_frame
	
	control.release_focus()


func _active_input(input):
	if input.is_action_pressed("Joypad Leave"):
		emit_signal("deactivate", device)
		return
	if focus != null:
		var new_focus
		if input.is_action_pressed("ui_up"):
			new_focus = focus.find_valid_focus_neighbor(SIDE_TOP)
		if input.is_action_pressed("ui_down"):
			new_focus = focus.find_valid_focus_neighbor(SIDE_BOTTOM)
		if input.is_action_pressed("ui_left"):
			new_focus = focus.find_valid_focus_neighbor(SIDE_LEFT)
		if input.is_action_pressed("ui_right"):
			new_focus = focus.find_valid_focus_neighbor(SIDE_RIGHT)
		if new_focus:
			if is_ancestor_of(new_focus):
				focus = new_focus
				queue_redraw()
		
		if input.is_action_pressed("ui_accept"):
			click_on_control(focus)
			#focus.emit_signal("pressed")


func _input(input : InputEvent):
	if input.device != device:
		return
	
	if state == PLAYER_CARD_STATES.INACTIVE:
		return
	
	if state == PLAYER_CARD_STATES.ACTIVE:
		_active_input(input)
	
	if state == PLAYER_CARD_STATES.READY:
		if input.is_action_pressed("Joypad Leave"):
			state = PLAYER_CARD_STATES.ACTIVE

func get_color():
	return PLAYER_COLOR_LIST[current_color]

func set_current_color(new_color):
	current_color = new_color
	%PlayerImage.modulate = get_color()

func _on_previous_color_pressed():
	current_color = (current_color - 1) % len(PLAYER_COLOR_LIST)


func _on_next_color_pressed():
	current_color = (current_color + 1) % len(PLAYER_COLOR_LIST)


func _on_ready_pressed():
	state = PLAYER_CARD_STATES.READY

func get_player_data():
	return {
		"device": device,
		"color": get_color()
	}
