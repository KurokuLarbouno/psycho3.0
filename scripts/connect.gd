extends Node

# Default game port
const DEFAULT_PORT = 10567

# Max number of players
const MAX_PEERS = 4
#-------------------------------trap>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

#陷阱隨機參數設定
const Trap_spwan_num = 7# 陷阱生成點數量
const Trap_type = 6# 擺上去的陷阱種類數
var generate_points_num = []# 陷阱生成點編號

#---------------------------------->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
var random_num
#-------------------------------trap END
# Name for my player
var player_name = "The Warrior"

# Names for remote players in id:name format
var players = {}
var select_save ={}
var select_save_order ={}
var player_die_num ={}#玩家死亡次數
var player_kill_num ={}#玩家殺敵次數
var player_grade={}#玩家排名
var map
var p_order ={}
var players_all
# Signals to let lobby GUI know what's going on

signal player_list_changed()
signal player_reflesh()
signal connection_failed()
signal connection_succeeded()
signal game_ended()
signal game_error(what)



# Callback from SceneTree
func _player_connected(id):
	# This is not used in this demo, because _connected_ok is called for clients
	# on success and will do the job.
	pass

# Callback from SceneTree
func _player_disconnected(id):
	if (get_tree().is_network_server()):
		if (has_node("/root/Game")): # Game is in progress
			emit_signal("game_error", "Player " + players[id] + " disconnected")
			end_game()
		else: # Game is not in progress
			# If we are the server, send to the new dude all the already registered players
			unregister_player(id)
			for p_id in players:
				# Erase in the server
				rpc_id(p_id, "unregister_player", id)

#成功連線到sever時，註冊自己
# Callback from SceneTree, only for clients (not server)
func _connected_ok():

	# Registration of a client beings here, tell everyone that we are here
	rpc("register_player", get_tree().get_network_unique_id(), player_name)
	print("_connected_ok")
	print(get_tree().get_network_unique_id())
	emit_signal("connection_succeeded")
	#rpc_id(1,"set_p_order",1,1)

# Callback from SceneTree, only for clients (not server)
func _server_disconnected():
	emit_signal("game_error", "Server disconnected")
	end_game()

# Callback from SceneTree, only for clients (not server)
func _connected_fail():
	get_tree().set_network_peer(null) # Remove peer
	emit_signal("connection_failed")

# Lobby management functions

#成功連線之後註冊自己
remote func register_player(id, name):
	if (get_tree().is_network_server()):
		# If we are the server, let everyone know about the new player
		rpc_id(id, "register_player", 1, player_name) # Send myself to new dude
		for p_id in players: # Then, for each remote player
			rpc_id(id, "register_player", p_id, players[p_id]) # Send player to new dude
			rpc_id(p_id, "register_player", id, name) # Send new dude to player
	players[id] = name
	if (get_tree().is_network_server()):
		var i = 1
		var cur_kind = get_node("/root/Lobby/").cur_kind
		var map_cur_kind =  get_node("/root/Lobby/").maps[get_node("/root/Lobby/").map_cur_kind]
		
		for p_id in players:
			i += 1
			rpc_id(p_id,"set_p_order",p_id,i)  
			rpc_id(p_id,"sync_map_and_kind",p_id,cur_kind,map_cur_kind)  
			pass
		pass
	emit_signal("player_list_changed")
remote func unregister_player(id):
	players.erase(id)
	emit_signal("player_list_changed")
	if (get_tree().is_network_server()):
		emit_signal("player_reflesh")
#角色加入時同步已經設定的
remote func sync_map_and_kind(id,cur_kind,map_cur_kind):
	print("QAQ")
	get_node("/root/Lobby/map_icon").texture = load("res://image/StartEnd/" + str(map_cur_kind) + ".png")
	get_node("/root/Lobby/").map_cur_kind = map_cur_kind
	pass
remote func set_p_order(id,v_p_order):
	p_order[id] = v_p_order
	print("set_p_order")
	get_node("/root/Lobby/players/player"+str(v_p_order)+"/right").show()
	get_node("/root/Lobby/players/player"+str(v_p_order)+"/left").show()
	get_node("/root/Lobby/players/player"+str(v_p_order)+"/ready").show()
	get_node("/root/Lobby/players/player"+str(v_p_order)+"/select").show()
	
	pass
#step4 所有玩家執行此函式預備遊戲
remote func pre_start_game(spawn_points, var_generate_points_num):

#--------------------------------------------舊的東東
	# Change scene
	print(load("res://scene/fire.tscn"))
	var world = load("res://scene/" + map + ".tscn").instance()
	get_tree().get_root().add_child(world)
	if(get_tree().get_root().get_node("Lobby")):get_tree().get_root().get_node("Lobby").queue_free()
	#var player_scene = load("res://scene/Player.tscn")#載入玩家
 
	var trap_scene = load("res://scene/trap.scn")#loadtrap
	generate_points_num = var_generate_points_num#>>>>>>>>>>>>>>>>>>>>>>>
	#print("進入connect陷阱設置階段")
	#如未結束請檢查陷阱數量以及生成點數量的相關變數(Trap_spwan_num)
	
	for i in Trap_type:
		var trap = trap_scene.instance()#loadtrap
		var spawn_pos = world.get_node("Roof/Trap_Point/Position"+generate_points_num[i]).position
		trap.set_network_master(1) #set unique id as master
		trap.position = spawn_pos
		trap.set_name(str(i))
		world.get_node("Roof/Trap").add_child(trap)
	#print("離開connect陷阱設置階段")
#載入陷阱 END
	for p_id in spawn_points:
		
		#var spawn_pos = world.get_node("Player_Point/Position"+str(spawn_points[p_id])).get_position()
		var spawn_pos = world.get_node("Roof/Player_Point/Position"+str(spawn_points[p_id])).position
		var player = load("res://scene/" + select_save[p_id] + ".tscn").instance()
		player.set_name(str(p_id)) # Use unique ID as node name
		#player.set_position(spawn_pos)
		player.position = spawn_pos
		player_die_num[p_id] = 0
		player_kill_num[p_id] = 0
		player.set_network_master(p_id) #set unique id as master

		if (p_id == get_tree().get_network_unique_id()):
			# If node for this peer id, set name
			player.set_player_name(player_name)
		else:
			# Otherwise set name from peer
			player.set_player_name(players[p_id])

		world.get_node("Roof/Player").add_child(player)
	if (get_tree().is_network_server()):
		get_node("/root/Game/Camera/Camera2D/UI").ui_set()
	# Set up score
#	world.get_node("score").add_player(get_tree().get_network_unique_id(), player_name)
#	for pn in players:
#		world.get_node("score").add_player(pn, players[pn])
#
	if (not get_tree().is_network_server()):
		# Tell server we are ready to start
		rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())
	elif players.size() == 0:
		post_start_game()

#step6 結束暫停等待，使遊戲開始 
remote func post_start_game():
	get_tree().set_pause(false) # Unpause and unleash the game!

var players_ready = []

#step5 告訴非sever玩家要開始遊戲了
remote func ready_to_start(id):
	assert(get_tree().is_network_server())

	if (not id in players_ready):
		players_ready.append(id)

	if (players_ready.size() == players.size()):
		for p in players:
			rpc_id(p, "post_start_game")
		post_start_game()
#step1 創立server
func host_game(name):
	player_name = name
	var host = NetworkedMultiplayerENet.new()
	host.create_server(DEFAULT_PORT, MAX_PEERS)
	get_tree().set_network_peer(host)
	#rpc_id(1,"set_p_order",1,1)
	set_p_order(1,1)

	
#step2 使用者加入server
func join_game(ip, name):
	var data = {
	    ip = ip,
	    name = name
	}
	print(data)
	# Open a file
	var file = File.new()
	if file.open("res://save/saved_game.save", File.WRITE) != 0:
	    print("Error opening file")
	    return
	# Save the dictionary as JSON (or whatever you want, JSON is convenient here because it's built-in)
	file.store_line(to_json(data))
	
	file.close()

	player_name = name
	var host = NetworkedMultiplayerENet.new()
	host.create_client(ip, DEFAULT_PORT)
	get_tree().set_network_peer(host)
	
func get_player_list():
	return players.values()

func get_player_name():
	return player_name
#step3 遊戲開始
func begin_game():
	assert(get_tree().is_network_server())

	
	var random_num_flag = false
	for i in Trap_type:
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
	# Create a dictionary with peer id and respective spawn points, could be improved by randomizing

	var spawn_points = {}#生成點
	spawn_points[1] = 0 # Server in spawn point 0
	var spawn_point_idx = 1
	for p in players:
		spawn_points[p] = spawn_point_idx
		spawn_point_idx += 1
	# Call to pre-start game with the spawn points
	for p in players:
		rpc_id(p, "pre_start_game", spawn_points, generate_points_num)

	pre_start_game(spawn_points, generate_points_num)

#------------------結束遊戲，斷線
func end_game():
	if (has_node("/root/Game")): # Game is in progress
		# End it
		get_node("/root/Game").queue_free()
	emit_signal("game_ended")
	players.clear()
	get_tree().set_network_peer(null) # End networking
#------------------結束遊戲，斷線 END
func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("server_disconnected", self, "_server_disconnected")



