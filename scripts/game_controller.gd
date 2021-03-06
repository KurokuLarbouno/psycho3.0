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
var ending = "res://scene/end_scene.tscn"
var game
var upgrade = "res://scene/upgrade.tscn"
var cTime = 0 #開始遊戲前倒數
var rTime = 0 #回合時間
var rTime_total = 90
var round_count = 0
var total_round = 4

var loadingState = 0 #check state for timer 0:Init 1:loaded 
var gameState = 0
var player_data = [[0, 0, 0],[0, 0, 0],[0, 0, 0],[0, 0, 0]]
var player_stats = [[10, 5000, 1, 0.5, 200],[10, 5000, 1, 0.5, 200],[10, 5000, 1, 0.5, 200],[10, 5000, 1, 0.5, 200]] #血量、移動、充彈速度、攻擊速度、子彈速度
var player_score = [[0,0],[0,0],[0,0],[0,0]] # killpoints / deadpoints
var final_score = [[0,0],[0,0],[0,0],[0,0]]
var upgrade_stats = [[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0],[0,0,0,0,0]]
#陷阱隨機參數設定
const Trap_spwan_num = 6# 陷阱生成點數量
const Trap_type = 6# 擺上去的陷阱種類數
var generate_points_num = []# 陷阱生成點編號

func _ready():
	game = game1
	pass

func _process(delta):
	if(gameState == 0):
		emit_signal("int_game")
		$UI/playerUI.show()
		_load_game(game)
		$Camera2D.current = true
		gameState = 1
	elif(gameState == 1):
		round_count += 1
		spawn_player()
		print("spawn players")
		#等待轉場結束才會進入 state2-遊戲
		$UI/countdown.visible = false
		$Transition/slice/AnimationPlayer.play( "opening3" )
		$Timer.set_wait_time($Transition/slice/AnimationPlayer.current_animation_length)
		$Timer.start()
		gameState = 1.5
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
		#等待轉場結束才會進入 state5-升級
		$Transition/slice/AnimationPlayer.play( "ready" )
		$Timer.set_wait_time($Transition/slice/AnimationPlayer.current_animation_length)
		$Timer.start()
		gameState = 4.5
	elif(gameState == 5):
		if(next_round):
			#等待轉場結束才會進入 state6-切換遊戲
			$Transition/slice/AnimationPlayer.play( "ready" )
			$Timer.set_wait_time($Transition/slice/AnimationPlayer.current_animation_length)
			$Timer.start()
			change_scene()
			next_round = false
			gameState = 5.5
	pass
	
var cur_game = ""
func _load_game(scn):
	cur_game = scn
	
	var children = $game_scene.get_children()
	if(children.size() > 0):
		for i in range(children.size()):
			children[i].queue_free()
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
			#釋放舊的UI
			var UI_children = get_node("UI/playerUI/player" + str(i+1)).get_children()
			for j in range(UI_children.size()):
				UI_children[j].queue_free()
			var player =  load("res://scene/player.tscn").instance()
			var player_ui = load("res://scene/player_UI.tscn").instance()
			#設定玩家資訊(從main給)
			var cur_scene = $game_scene.get_children()
			cur_scene = cur_scene[0]
			player.player_num = i
			player_ui.player_num = i + 1
			player.input_device = player_data[i][1]
			player.player_type = player_data[i][2]
			player_ui.player_type = player_data[i][2]
			player.position = get_node("game_scene/Game/Roof/Player_Point/Position" + str(i+1)).position
			player.player_stats = player_stats
			player.player_score = player_score
			ctrl_connect_player(player)
			ctrl_connect_trap_effect(player.get_node("TrapEffect"))
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
	generate_points_num = []
	for i in range(Trap_type):
		randomize()
		random_num = str(randi()%Trap_spwan_num)
		var unlimit_loop = 0
		while 1:
			unlimit_loop += 1
			random_num_flag = false
			for index in range(generate_points_num.size()):
				if(generate_points_num[index] == random_num):
					randomize()
					random_num = str( randi()%Trap_spwan_num )
					random_num_flag = true
					break
			if random_num_flag == false : break
			if unlimit_loop > 10000000 : 
				print("random生成trap ERROR")
				break
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
		$UI/countdown.show()
		$UI/filter.show()
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
	print("set upgrade stats")
	$game_scene/upgrade.upgrade_stats = upgrade_stats
	$game_scene/upgrade.connect("next_round", self, "_next_round")
	pass
var next_round = false
func _next_round():
	next_round = true
	pass
func change_scene():
	if(game == game1):
		game = game2
	else :
		game = game1
	pass

func _on_Timer_timeout():
	if(loadingState == 0):
		$UI/countdown.visible = true
		loadingState = 1
		gameState = 2
	elif(loadingState == 1):
		$Transition/slice/AnimationPlayer.play( "opening2" )
		loadingState = 2
		if(round_count >= total_round):
			end_scene()
		else : upgrade()
		gameState = 5
	elif(loadingState == 2):
		loadingState = 0
		gameState = 0
	pass
func _update_score(killer,die):
	player_score[killer][0] += 1
	player_score[die][1] += 1
	final_score[killer][0] += 1
	final_score[die][1] += 1
	print(player_score)
	pass
func ctrl_connect_player(obj):
	obj.connect("update_score", self,"_update_score")
	obj.connect("hurt", self, "_hurt")
	#obj.connect("hurt", self, "_hurt")
	pass
func ctrl_connect_trap_effect(obj):
	obj.connect("mirage", self, "_mirage")
	pass
func end_scene():
	$UI/playerUI.hide()
	_load_game(ending)
	$game_scene/end_scene.player_data = player_data
	$game_scene/end_scene.final_score = final_score
	pass
func _hurt():
	$Camera2D/Anim_Effect.play("shake")
	#$game_scene/end_scene.final_score = final_score
	#$game_scene/end_scene.player_score = player_score
	pass
func _mirage():
	$Camera2D.mirage_flag = true
	$Camera2D.mirage_time = 0
	$Camera2D.mirage_time_control=30
	pass