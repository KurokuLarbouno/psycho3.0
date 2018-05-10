extends Node2D

signal int_game
signal game_over

var game1 = "res://scene/Game2.tscn"
var game2 = "res://scene/Game.tscn"

var gameState = 0
var player_data = [[0, 0],[0, 0],[0, 0],[0, 0]]

func _ready():
	# Called every time the node i added to the scene.
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
			player.player_num = i
			player_ui.player_num = 1
			player.input_device = player_data[i][1]
			player.player_type = player_data[i][2]
			player_ui.player_type = player_data[i][2]
			player.position = get_node("game_scene/Game/Roof/Player_Point/Position" + str(i+1)).get_position()
			get_node("game_scene/Game/Roof/Player").add_child(player)
			get_node("UI/playerUI/player" + str(i+1)).add_child(player_ui)
	pass
