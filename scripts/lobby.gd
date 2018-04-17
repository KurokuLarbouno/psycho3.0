extends Control

var maps = ["Game", "Game2"]#--------------------玩家選取功能
var kind = ["c1", "c2", "c3", "c4"]
var cur_kind = 0
var map_cur_kind = 0
var p_order_count = 1	# 玩家暫存編號
#var p_order = 1			# 玩家自身編號
var self_kind = ''		# 玩家鎖定後的種類
var now_kind 			# 玩家目前種類
#游標
var arrow = load("res://image/cursor/cursor.png")
var beam = load("res://image/cursor/beam.png")
#-------------------------------------------------------
func _ready():
	#游標
	Input.set_custom_mouse_cursor(arrow, 0, Vector2(16,16))
	Input.set_custom_mouse_cursor(beam, Input.CURSOR_IBEAM, Vector2(16,16))
	get_node("map_icon").texture = load("res://image/StartEnd/" +maps[0]+".png")
	var file = File.new()
	var data = {}
	now_kind = kind[0]
	if(get_tree().get_root().get_node("players_old")):
		get_tree().get_root().get_node("players_old").queue_free()
	if not file.file_exists("res://save/saved_game.save"):
	    print("No file saved!")
	    #return
	# Open existing file
	if file.open("res://save/saved_game.save", File.READ) != 0:
	    print("Error opening file")
	    #return
	# Get the data
	else:
		data = parse_json(file.get_line())
		# Then do what you want with the data
		get_node("connect/ip").text = data.ip
		get_node("connect/name").text = data.name	
	connect.connect("connection_failed", self, "_on_connection_failed")
	connect.connect("connection_succeeded", self, "_on_connection_success")
	connect.connect("player_list_changed", self, "refresh_lobby")
	#connect.connect("player_reflesh", self, "refresh_lobby")
	connect.connect("game_ended", self, "_on_game_ended")
	connect.connect("game_error", self, "_on_game_error")
	get_tree().connect("network_peer_disconnected", self,"refresh_player")

func _on_host_pressed():
	if (get_node("connect/name").text == ""):
		get_node("connect/error_label").text="Invalid name!"
		return

	get_node("connect").hide()
	get_node("map_ui").show()
	get_node("players").show()
	get_node("map_icon").show()
	get_node("maps").show()
	get_node("connect/error_label").text=""
	
	
	var name = get_node("connect/name").text
	connect.host_game(name)
	refresh_lobby()
	
	#get_node("players/player"+str(connect.p_order[get_tree().get_network_unique_id()])+"/right").show()
	#get_node("players/player"+str(connect.p_order[get_tree().get_network_unique_id()])+"/left").show()
	#get_node("players/player"+str(connect.p_order[get_tree().get_network_unique_id()])+"/ready").show()
func _on_join_pressed():
	#print("player"+str(p_order))
	if (get_node("connect/name").text == ""):
		get_node("connect/error_label").text="Invalid name!"
		return

	var ip = get_node("connect/ip").text
	if (not ip.is_valid_ip_address()):
		get_node("connect/error_label").text="Invalid IPv4 address!"
		return

	get_node("connect/error_label").text=""
	get_node("connect/host").disabled=true
	get_node("connect/join").disabled=true

	var name = get_node("connect/name").text
	connect.join_game(ip, name)
	# refresh_lobby() gets called by the player_list_changed signal
	#print(get_node("players/player"+str(p_order)+"/right"))
	
	
func _on_connection_success():
	get_node("connect").hide()
	get_node("map_ui").show()
	get_node("players").show()
	get_node("map_icon").show()
	get_node("maps").show()
	

func _on_connection_failed():
	get_node("connect/host").disabled=false
	get_node("connect/join").disabled=false
	get_node("connect/error_label").set_text("Connection failed.")

func _on_game_ended():
	show()
	get_node("connect").show()
	get_node("players").hide()
	get_node("connect/host").disabled=false
	get_node("connect/join").disabled

func _on_game_error(errtxt):
	get_node("error").text=errtxt
	get_node("error").popup_centered_minsize()

func refresh_lobby():
	var players = connect.get_player_list()
	players.sort()
	get_node("players/list").clear()
	get_node("players/list").add_item(connect.get_player_name() + " (You)")
	for p in players:
#		if (get_tree().is_network_server()):
#			p_order_count = 1
#			for p_id in connect.players:
#				p_order_count += 1
#				rpc_id(p_id, "player_order", p_order_count) 
		get_node("players/list").add_item(p)
		#print("QAQ"+p)
		#get_node("players/player"+str(connect.p_order[get_tree().get_network_unique_id()])+"/right").show()
		#get_node("players/player"+str(connect.p_order[get_tree().get_network_unique_id()])+"/left").show()
		#get_node("players/player"+str(connect.p_order[get_tree().get_network_unique_id()])+"/ready").show()


#---------------------------------------------------------------HOST設定指定ID的玩家順序
remote func player_order(v_p_oder):
	#p_order = v_p_oder
	pass
#---------------------------------------------------------------HOST遊戲開始
func _on_start_pressed():
	rpc("save_map",maps[map_cur_kind])
	connect.begin_game()
	pass
#---------------------------------------------------------------玩家種類選取介面
func _on_right_pressed():
	cur_kind = (cur_kind+1)%(kind.size())
	rpc("set_player_icon",connect.p_order[get_tree().get_network_unique_id()],kind[cur_kind])
	now_kind = kind[cur_kind]
	pass # replace with function body
#---------------------------------------------------------------玩家種類選取介面
func _on_left_pressed():
	cur_kind = cur_kind-1
	if cur_kind < 0: cur_kind = kind.size()-1
	rpc("set_player_icon", connect.p_order[get_tree().get_network_unique_id()],kind[cur_kind])
	now_kind = kind[cur_kind]
	pass # replace with function body
#---------------------------------------------------------------場地種類選取介面
func _on_right_map_pressed():
	map_cur_kind = (map_cur_kind+1)%(maps.size())
	rpc("set_map_icon", maps[map_cur_kind])
	rpc("save_map_select",maps[map_cur_kind])

	pass # replace with function body
#---------------------------------------------------------------場地種類選取介面
func _on_left_map_pressed():
	map_cur_kind = map_cur_kind-1
	if map_cur_kind < 0: map_cur_kind = maps.size()-1
	rpc("set_map_icon", maps[map_cur_kind])
	rpc("save_map_select",maps[map_cur_kind])
	pass # replace with function body
#---------------------------------------------------------------設定玩家縮圖
sync func set_map_icon(var p_file):
	get_node("map_icon").texture = load("res://image/StartEnd/" + p_file +".png")
	get_node("maps/Label").text = p_file
	pass
#---------------------------------------------------------------設定玩家縮圖
sync func set_player_icon(var p_order,var p_file):
	get_node("players/player" + str(p_order) + "/player_icon").texture = load("res://image/StartEnd/" + p_file +".png")
	set_player_name(p_order, p_file)
	print(p_file)
	if(p_file):
		if(p_file == "c1"):
			set_player_name(p_order, "Slice")
		if(p_file == "c2"):
			set_player_name(p_order, "Acid")
		if(p_file == "c3"):
			set_player_name(p_order, "Phase")
		if(p_file == "c4"):
			set_player_name(p_order, "Beast")
	pass
sync func set_btn_state(var p_order):
	get_node("players/player" + str(p_order) + "/ready").show()
	get_node("players/player" + str(p_order) + "/ready").disabled = true
	pass
func set_player_name(var p_order,var name):
	get_node("players/player" + str(p_order) + "/Label").text = "P"+str(p_order)+": " + name
	pass
#---------------------------------------------------------------鎖定選擇，重新定義可選種類
sync func set_player_bind(var p_file):
	for index in range(kind.size()):
		if kind[index] == p_file:
			kind.remove(index)
			break
	if self_kind == '':
		if now_kind == p_file:
			cur_kind = (cur_kind+1)%(kind.size())
			now_kind = kind[cur_kind]
			get_node("players/player" + str(connect.p_order[get_tree().get_network_unique_id()]) + "/player_icon").texture = load("res://image/StartEnd/" + kind[cur_kind]+".png")
			rpc("set_player_icon",connect.p_order[get_tree().get_network_unique_id()],kind[cur_kind])
		pass
	pass
#---------------------------------------------------------------儲存進房後順位及相應種類
sync func save_player_select(var p_id,var p_file,var order):
	connect.select_save[p_id] = p_file
	connect.select_save_order[p_id] = order
	print(connect.select_save_order)
	print(p_file)
	pass
#---------------------------------------------------------------玩家離線，離線者選擇種類回補
sync func refresh_player(id):
	kind.append(connect.select_save[id])
	
	if (get_tree().is_network_server()):
		p_order_count = 1
		for p_id in connect.players:
			p_order_count += 1
			rpc_id(p_id, "player_order", p_order_count) 
			rpc_id(p_id, "reset_player") 
	pass
#---------------------------------------------------------------玩家離線，玩家遞補
remote func reset_player():
	var reg_cur_kind
	if self_kind != '':
		if connect.p_order[get_tree().get_network_unique_id()] != connect.select_save_order[get_tree().get_network_unique_id()]:
			reg_cur_kind = (cur_kind+1)%(kind.size())
			rpc("set_player_icon",connect.select_save_order[get_tree().get_network_unique_id()],kind[reg_cur_kind])
			rpc("set_player_icon",connect.p_order[get_tree().get_network_unique_id()],self_kind)
	pass	
#---------------------------------------------------------------玩家選取鎖定
func _on_ready_pressed():
	self_kind = kind[cur_kind]
	rpc("save_player_select",get_tree().get_network_unique_id(),kind[cur_kind],connect.p_order[get_tree().get_network_unique_id()])
	rpc("set_player_bind",kind[cur_kind])
	rpc("set_btn_state",connect.p_order[get_tree().get_network_unique_id()])
	print(str(get_tree().get_network_unique_id()))
	get_node("players/player"+str(connect.p_order[get_tree().get_network_unique_id()])+"/ready").disabled=true
	get_node("players/player"+str(connect.p_order[get_tree().get_network_unique_id()])+"/right").visible=false
	get_node("players/player"+str(connect.p_order[get_tree().get_network_unique_id()])+"/left").visible=false
	rpc("switch_map_menu")
	get_node("maps/start").disabled=not get_tree().is_network_server()
	if (get_tree().is_network_server()):get_node("maps/start").show()
	pass # replace with function body
#-----------------------------------------------------------------進入地圖選單
	pass # replace with function body
#-----------------------------------------------------------------同步進入地圖選單
sync func switch_map_menu():
	if (not get_tree().is_network_server()):
		get_node("maps/start").disabled=true
		get_node("map_ui/right_map").disabled=true
		get_node("map_ui/left_map").disabled=true
	pass
sync func save_map(map):
	connect.map	= map
	pass






func _on_Ready_pressed():
	pass # replace with function body
