extends Control

func _ready():
	for Card in %Cards.get_children():
		Card.connect("deactivate", remove_player)
		Card.connect("player_ready", player_ready)

func find_card_device(device):
	for Card in %Cards.get_children():
		if Card.device == device:
			return Card
	return false

func add_player(device):
	var Card = find_card_device(null)
	if Card:
		Card.device = device

func remove_player(device):
	var Card = find_card_device(device)
	if Card:
		Card.device = null

func is_everyone_ready():
	var ready = 0
	for Card in %Cards.get_children():
		if Card.is_active_and_not_ready():
			return false
		if Card.is_ready():
			ready += 1
	if ready == 0:
		return false
	return true

func player_ready():
	if is_everyone_ready():
		start_game()

func start_game():
	var player_data = []
	for Card in %Cards.get_children():
		if Card.is_ready():
			player_data.append(Card.get_player_data())
	GameManagerAutoload.player_data = player_data
	GameManagerAutoload.reset_score()
	LevelManagerAutoload.transition_to("res://Scenes/Play/Play.tscn")

func is_joypad_attached(device):
	var Card = find_card_device(device)
	if Card:
		return true
	return false

func _input(event):
	if (event is InputEventJoypadMotion) or (event is InputEventMouseMotion):
		return
	if event.is_action_pressed("Joypad Join"):
		if not is_joypad_attached(event.device):
			add_player(event.device)
	if event.is_action_pressed("Joypad Leave"):
		if not is_joypad_attached(event.device):
			LevelManagerAutoload.transition_to("res://Scenes/Menu/MainMenu/MainMenu.tscn")



func _on_back_button_pressed():
	LevelManagerAutoload.transition_to("res://Scenes/Menu/MainMenu/MainMenu.tscn")
