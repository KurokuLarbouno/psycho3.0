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
var rTime_total = 3

var gameState = 0
var player_data = [[0, 0, 0],[0, 0, 0],[0, 0, 0],[0, 0, 0]]
var player_stats = [[25, 5000, 1, 0.2, 200],[20, 5000, 1, 0.2, 200],[20, 5000, 1, 0.2, 200],[20, 5000, 1, 0.2, 200]] #血量、移動、充彈速度、攻擊速度、子彈速度
var player_score = [[0,0],[0,0],[0,0],[0,0]] # killpoints / deadpoints

#陷阱隨機參數設定
const Trap_spwan_num = 6# 陷阱生成點數量
const Trap_type = 3# 擺上去的陷阱種類數
var generate_points_num = []# 陷阱生成點編號

func _ready():
	#$UI/slice.connect("start", self, "load_next_scene")
	playing_game = game1
	pass

func _process(delta):
	if(gameState == 0):
		emit_signal("int_game")
		_load_game(game1)
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
		upgrade()
		gameState = 5
	elif(gameState == 5):
		if(next_round):
			next_round = false
			gameState = 1

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
	var trap_scene
	for i in range(4):
		if(player_data[i][0] == 1):#確認是否有玩家
			var player =  load("res://scene/player.tscn").instance()
			var player_ui = load("res://scene/player_UI.tscn").instance()
			#設定玩家資訊(從main給)
			player.player_num = i
			player_ui.player_num = 1
			player.input_device = player_data[i][1]
			player.player_type = player_data[i][2]
			player_ui.player_type = player_data[i][2]
			player.position = (get_node("game_scene/Game/Roof/Player_Point/Position" + str(i+1))).position
			player.player_stats = player_stats
			player.player_score = player_score
			cur_scene.get_node("Roof/Player").add_child(player)
			get_node("UI/playerUI/player" + str(i+1)).add_child(player_ui)
			player_ui.connect_player(player)
			player.int_ui()
			trap_scene = cur_scene
	if(player_data[0][0] == 1):#確認至少有一位玩家
		spawn_trap(trap_scene)
		print("spawn trap")
	pass
func spawn_trap(cur_scene):
	var random_num_flag = false
	var random_num = 0

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
	cur_scene.get_node("Roof/Trap").generate_points_num = generate_points_num
	cur_scene.get_node("Roof/Trap").Trap_spwan_num = Trap_spwan_num
		#陷阱隨機參數設定 END
	for i in range(Trap_type):
		var trap_scene = load("res://scene/trap_local.scn")#loadtrap
		#如果錯誤請檢查陷阱數量以及生成點數量的相關變數(Trap_spwan_num)
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
func upgrade():
	$UI/playerUI.hide()
	_load_game(upgrade)
	if($game_scene.get_children().size() > 0):
		$game_scene/upgrade.player_stats = player_stats
		$game_scene/upgrade.player_score = player_score
	$game_scene/upgrade.connect("next_round", self, "_next_round")
	pass
var next_round = false
func _next_round():
	next_round = true
	pass