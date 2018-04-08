extends Panel

var players_all
func _ready():
	players_all = connect.players_all
	grade()
	pass
func grade():#排名程式
	connect.player_kill_num
	connect.player_die_num
	connect.player_grade
	var i = 0
	for p_id in connect.player_kill_num:
		connect.player_grade[i] = p_id
		i +=1
		pass
	#--------------------------------------------------------------------排序名次
	var bubble_flag = true
	var switch_num
	while bubble_flag:
		bubble_flag = false
		for index in range(connect.select_save_order.size()-1):
			if connect.player_kill_num[connect.player_grade[index]] < connect.player_kill_num[connect.player_grade[index+1]]:
				switch_num = connect.player_grade[index]
				connect.player_grade[index] = connect.player_grade[index+1]
				connect.player_grade[index+1] = switch_num
				bubble_flag = true
				pass
			if connect.player_kill_num[connect.player_grade[index]] == connect.player_kill_num[connect.player_grade[index+1]]:
				if connect.player_die_num[connect.player_grade[index]] > connect.player_die_num[connect.player_grade[index+1]]:
					switch_num = connect.player_grade[index]
					connect.player_grade[index] = connect.player_grade[index+1]
					connect.player_grade[index+1] = switch_num
					bubble_flag = true
					pass
				pass
			pass
		pass
	#--------------------------------------------------------------------印出名次
	for index in range(connect.select_save_order.size()):
		#get_node("players_old/list").clear()
		get_node("list").add_item("Rank:"+str(index+1)+"  P"+str(connect.select_save_order[connect.player_grade[index]])+" Name:"+str(players_all[connect.player_grade[index]])+" "+"Kill:"+str(connect.player_kill_num[connect.player_grade[index]])+" Death:"+str(connect.player_die_num[connect.player_grade[index]]))
		#get_node("list").add_item()

	pass#---------------------------grade END

func _on_END_pressed():
	if (has_node("/root/Game")): # Game is in progress
		# End it
		print("QAQ")
		get_node("/root/Game").queue_free()
	if (has_node("/root/lobby")): # Game is in progress
		# End it
		print("QAQ")
		get_node("/root/lobby").queue_free()
	
	connect.players.clear()
	connect.generate_points_num = []
	connect.select_save.clear()
	connect.select_save_order.clear()
	connect.player_die_num.clear()
	connect.player_kill_num.clear()
	connect.player_grade.clear()
	connect.p_order.clear()
	print(get_tree().get_root().get_children())
	get_tree().set_network_peer(null) # End networking
	var lobby = load("res://scene/lobby.tscn").instance()
	if(get_tree().get_root().get_node("lobby")):
		print("QAQ")
		get_tree().get_root().get_node("lobby").queue_free()
	get_tree().get_root().add_child(lobby)
	if(get_tree().get_root().get_node("ending")):
		print("QAQ")
		get_tree().get_root().get_node("end").queue_free()
	self.queue_free()
	print(self.get_parent().get_name())
	print(self.get_name())
	if (get_tree().get_root().get_node("player_old")): # Game is in progress
		print("QAQ")
		# End it
		get_node("/root/ending").queue_free()
	
	pass # replace with function body
