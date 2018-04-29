extends Node2D

var player1_data = [0,0]

var waiting_room = "res://scene/waiting_room.tscn"
var game_control = "res://scene/game_controller.tscn"


func _ready():
	_load_scene("res://scene/lobby.tscn")
	pass

func _process(delta):
	pass

#載入Scene
var cur_scn = ""
var loadState = 0
func _load_scene(scn):
	print( "Loading level: ", scn, "   State: ", loadState )
	if loadState == 0:
		cur_scn = scn
		loadState = 1
		$loadTimer.set_wait_time(0.1)
		$loadTimer.start()
	elif loadState == 1:
		var children = $scene.get_children()
		if children.size() > 0:
			if children[0].has_method("is_level"):
				_disconnect_level(children[0])
			elif children[0].has_method("is_menu"):
				_disconnect_menu(children[0])
			children[0].queue_free()
			print("free children")
		loadState = 2
		$loadTimer.set_wait_time(0.1)
		$loadTimer.start()
	elif loadState == 2:
		var act = load(cur_scn).instance()
		if(act.has_method("is_level")):
			_connect_level(act)
		if(act.has_method("is_menu")):
			_connect_menu(act)
		$scene.add_child(act)
		loadState = 3
		$loadTimer.set_wait_time(0.1)
		$loadTimer.start()
	elif loadState == 3:
		loadState = 0
	pass
func _on_loadTimer_timeout():
	_load_scene(cur_scn)
	pass 
#game control
#scene connect
func _connect_level(obj):
	obj.connect("game_over", self, "_game_over")
	obj.connect("int_game", self, "_int_game")
	pass
func _disconnect_level(obj):
	obj.connect("game_over", self, "_game_over")
	obj.connect("int_game", self, "_int_game")
	pass
func _connect_menu(obj):
	obj.connect("join_local", self, "_join_local")
	obj.connect("start_game", self, "_start_game")
	obj.connect("player_register", self, "_player_register")
	print("menu connected!")
	pass
func _disconnect_menu(obj):
	obj.disconnect("join_local", self, "_join_local")
	obj.disconnect("start_game", self, "_start_game")
	obj.disconnect("player_register", self, "_player_register")
	print("menu disconnected!")
	pass
#ui pressed
func _join_local():
	print("join local")
	_load_scene(waiting_room)
	pass
#玩家確認
func _player_register(player_num, device_num):
	if(player_num == 1):
		player1_data[0] = 1
		player1_data[1] = device_num
	pass
#所有玩家ready觸發
func _start_game():
	
	_load_scene(game_control)
	pass
#load 完game_controller執行
func _int_game():

	pass
	
	

