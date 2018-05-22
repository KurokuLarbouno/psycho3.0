extends Node2D

signal start_game
signal player_register
signal set_player_character

var player_num = 0 #玩家數
var player1_device
var player2_device
var player3_device
var player4_device


func _ready():
	$CanvasLayer/slice/AnimationPlayer.play( "opening2" )
	$Camera2D.make_current()
	pass

func _process(delta):
	check_player_join_leave()
	#print(inputList)
	pass
	
var inputList = [0,1,2,3,4] #0-3是搖桿 4是鍵盤
var playerList = [-1,-1,-1,-1,-1]
func check_player_join_leave():
	#print(playerList)
	#搖桿
	for num in inputList:
		if(Input.is_joy_button_pressed(num, 0)):
			inputList[num] = -1
			playerList[num] = num
			register_player(num)
	for num in playerList:
		if(Input.is_joy_button_pressed(num, 1)):
			delete_player(num)
	#鍵盤
	if(Input.is_action_just_pressed("ui_select") and inputList[4] == 4):
		register_player(4)
		inputList[4] = -1
	if(Input.is_action_just_pressed("cancel") and inputList[4] == -1):
		delete_player(4)
		inputList[4] = 4
	pass
func register_player(num):
	var player = load("res://scene/waiting_room_player.tscn").instance()
	#設定玩家總數
	#對應搖桿編號與玩家編號
	player_num += 1
	if(player_num <= 4):
		if($player/player1.get_children().size() == 0):
			player1_device = num
			player.pname = "Player 1"
			player.device_num = num
			player.player_num = 1
			$player/player1.add_child(player)
			emit_signal("player_register", 0, num)
		elif($player/player2.get_children().size() == 0):
			player2_device = num
			player.pname = "Player 2"
			player.device_num = num
			player.player_num = 2
			$player/player2.add_child(player)
			emit_signal("player_register", 1, num)
		elif ($player/player3.get_children().size() == 0):
			player3_device = num
			player.pname = "Player 3"
			player.device_num = num
			player.player_num = 3
			$player/player3.add_child(player)
			emit_signal("player_register", 2, num)
		elif ($player/player4.get_children().size() == 0):
			player.pname = "Player 4"
			player4_device = num
			player.device_num = num
			player.player_num = 4
			$player/player4.add_child(player)
			emit_signal("player_register", 3, num)
		player_connect(player)
	else:
		print("maxed player!")
	pass
#Ｂ鍵取消玩家
func delete_player(num):
	#print("dd")
	player_num -= 1
	var children
	if(num == player1_device):
		children = get_node("player/player1").get_children()
		emit_signal("player_register", 0, -1)
	elif(num == player2_device):
		children = get_node("player/player2").get_children()
		emit_signal("player_register", 1, -1)
	elif(num == player3_device):
		children = get_node("player/player3").get_children()
		emit_signal("player_register", 2, -1)
	elif(num == player4_device):
		children = get_node("player/player4").get_children()
		emit_signal("player_register", 3, -1)
	if children.size() > 0:
		if(children[0].player_state == 0):
			children[0].exit()
			#playerList[num] = -1
			#inputList[num] = num
	pass
func ui_control():
	pass
func is_menu():
	pass
func check_all_player_ready():
	if(is_ready == player_num ):
		$CanvasLayer/slice/AnimationPlayer.play( "ready" )
		$Timer.set_wait_time($CanvasLayer/slice/AnimationPlayer.current_animation_length + 1)
		$Timer.start()
		pass
func check_character_repeat():
	pass
func player_connect(obj):
	obj.connect("player_ready", self,"_player_ready")
	obj.connect("player_delete", self,"_player_delete")
	print("player connected")
	pass
func player_disconnect(obj):
	obj.disconnect("player_ready", self,"_player_ready")
	obj.disconnect("player_delete", self,"_player_delete")
	print("player disconnected")
	pass
var is_ready = 0
func _player_ready(i, player_num, player_character):
	is_ready += i
	check_all_player_ready()
	emit_signal("set_player_character", player_num - 1, player_character)
	pass
func _player_delete(child):
	player_disconnect(child)
	child.queue_free()
	inputList[child.device_num] = child.device_num
	playerList[child.device_num] = -1
	print("player delete")
	pass
	

func _on_Timer_timeout():
	print("game started")
	emit_signal("start_game")
	pass 
