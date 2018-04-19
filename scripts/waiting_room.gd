extends Node2D

signal start_game
var player_num = 0 #玩家數
var player1_device
var player2_device
var player3_device
var player4_device


func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _process(delta):
	check_player_join_leave()
	pass
	
var joyList = [0,1,2,3,-1]
var playerList = [-1,-1,-1,-1,-1]
func check_player_join_leave():
	print(joyList)
	#搖桿
	for num in joyList:
		if(Input.is_joy_button_pressed(num, 0)):
			joyList[num] = -1
			playerList[num] = num
			register_player(num)
	for num in playerList:
		if(Input.is_joy_button_pressed(num, 1)):
			joyList[num] = num
			playerList[num] = -1
			delete_player(num)
	#電腦
	if(Input.is_action_just_pressed("ui_select")):
		register_player(4)
	pass
func register_player(num):
	var player = load("res://scene/waiting_room_player.tscn").instance()
	#設定玩家總數
	#對應搖桿編號與玩家編號
	if($player/player1.get_children().size() == 0):
		player1_device = num
		player.pname = "Player 1"
		$player/player1.add_child(player)
	elif($player/player2.get_children().size() == 0):
		player2_device = num
		player.pname = "Player 2"
		$player/player2.add_child(player)
	elif ($player/player3.get_children().size() == 0):
		player3_device = num
		player.pname = "Player 3"
		$player/player3.add_child(player)
	elif ($player/player4.get_children().size() == 0):
		player.pname = "Player 4"
		player4_device = num
		$player/player4.add_child(player)
	pass
func delete_player(num):
	player_num -= 1
	var children
	if(num == player1_device):
		children = get_node("player/player1").get_children()
	elif(num == player2_device):
		children = get_node("player/player2").get_children()
	elif(num == player3_device):
		children = get_node("player/player3").get_children()
	elif(num == player4_device):
		children = get_node("player/player4").get_children()
	if children.size() > 0:
		children[0].queue_free()
	pass

func is_menu():
	pass
func _on_start_pressed():
	emit_signal("start_game")
	pass # replace with function body
