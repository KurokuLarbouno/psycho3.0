extends Node2D

signal int_game
signal game_over

var playing_game
var count3 = load("res://image/GameScene/countdown1.png")
var count2 = load("res://image/GameScene/countdown2.png")
var count1 = load("res://image/GameScene/countdown3.png")
var count4 = load("res://image/GameScene/countdown4.png")

var game1 = "res://scene/Game2.tscn"
var game2 = "res://scene/Game1.tscn"
var upgrade = "res://scene/upgrade.tscn"
var cTime = 0 #開始遊戲前倒數
var rTime = 0 #回合時間
var rTime_total = 7

var gameState = 0
var player_data = [[0, 0, 0],[0, 0, 0],[0, 0, 0],[0, 0, 0]]

#陷阱隨機參數設定
const Trap_spwan_num = 6# 陷阱生成點數量
const Trap_type = 1# 擺上去的陷阱種類數


func _ready():
	$UI/slice.connect("start", self, "load_next_scene")
	playing_game = game1
	pass

func _process(delta):
	if(gameState == 0):
		emit_signal("int_game")
		_load_game(playing_game)
		$Camera2D.current = true
		gameState = 1
	elif(gameState == 1):
		spawn_player()
		print("spawn players")
		gameState = 2
	elif(gameState == 2):
		cTime += delta
		countDown(cTime)
		if(cTime >= 4.2):
			var players = $game_scene/Game/Roof/Player.get_children()
			for i in range(players.size()):
				players[i].setFreeze(false)
			gameState = 3
			cTime = 0
	elif(gameState == 3):
		rTime += delta
		if(rTime >=  rTime_total):
			$UI/Label.text = "party over"
			var players = $game_scene/Game/Roof/Player.get_children()
			for i in range(players.size()):
				players[i].setFreeze(true)
		if(rTime >= (rTime_total+2)):
			gameState = 4
			rTime = 0
	elif(gameState == 4):
		#$UI/slice.start()
		gameState = 5
		_load_game(upgrade)
	pass
	
var cur_game = ""
func _load_game(scn):
	cur_game = scn
	
	var children = $game_scene.get_children()
	if(children.size() > 0):
		children[0].queue_free()
		print("free game_scene")

	var act = load(cur_game).instance()
	$game_scene.add_child(act)
	print("game loaded")
	pass
func is_level():
	pass
func spawn_player():
	for i in range(4):
		if(player_data[i][0] == 1):#確認是否有玩家
			var player =  load("res://scene/player.tscn").instance()
			var player_ui = load("res://scene/player_UI.tscn").instance()
			#設定玩家資訊(從main給)
			var cur_scene = $game_scene.get_children()
			cur_scene = cur_scene[0]#陣列轉單一
			player.player_num = i
			player_ui.player_num = 1
			player.input_device = player_data[i][1]
			player.player_type = player_data[i][2]
			player_ui.player_type = player_data[i][2]
			player.position = (cur_scene.get_node("Roof/Player_Point/Position" + str(i+1))).position
			
			cur_scene.get_node("Roof/Player").add_child(player)
			get_node("UI/playerUI/player" + str(i+1)).add_child(player_ui)
			player_ui.connect_player(player)
			player.int_ui()
			spawn_trap(cur_scene)
			print("spawn trap")
	pass
func spawn_trap(cur_scene):
	var random_num_flag = false
	var random_num = 0
	var generate_points_num = []# 陷阱生成點編號
	for i in range(Trap_type):
		randomize()
		random_num = str(randi()%Trap_spwan_num)
		while 1:
			random_num_flag = false
			for index in range(generate_points_num.size()):
				if(generate_points_num[index] == random_num):
					randomize()
					random_num = str( randi()%Trap_spwan_num )
					random_num_flag = true
					break
			if random_num_flag == false : break
		generate_points_num.append( random_num )
		#陷阱隨機參數設定 END
		var trap_scene = load("res://scene/trap_local.scn")#loadtrap
		#如果錯誤請檢查陷阱數量以及生成點數量的相關變數(Trap_spwan_num)
		for i in Trap_type:
			var trap = trap_scene.instance()#loadtrap
			var spawn_pos = cur_scene.get_node("Roof/Trap_Point/Position"+generate_points_num[i]).position
			trap.position = spawn_pos
			trap.set_name(str(i))
			cur_scene.get_node("Roof/Trap").add_child(trap)
		#print("離開connect陷阱設置階段")
	pass
func countDown(t):
	if(t <= 1):
		$UI/Label.text = "3"
		$UI/countdown.texture = count3
	elif(t <= 2):
		$UI/Label.text = "2"
		$UI/countdown.texture = count2
	elif(t <= 3):
		$UI/Label.text = "1"
		$UI/countdown.texture = count1
	elif(t <= 4):
		$UI/Label.text = "Party Time"
		$UI/countdown.texture = count4
	elif(t <= 4.2):
		$UI/countdown.hide()
		$UI/filter.hide()
	pass
func load_next_scene():
	playing_game = game2
	gameState = 0
	pass
