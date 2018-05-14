extends ParallaxBackground
var sprite
var sprite_bullet
var players_all#這裡真正存了所有人！！！！
var heart
var bullet
var shift
var order
var hp
var bullet_amount
var spawn_pos
var start_flag = false
var loss_hp
var loss_bt
var timer = 0
func _ready():
	heart = load("res://image/Character/heart1.png")
	bullet = load("res://image/Character/bullet_ui.png")
	players_all = connect.players
	#players_all[get_tree().get_network_unique_id()] = connect.player_name
	pass
func _physics_process(delta):
	if start_flag:
		if (get_tree().is_network_server()):
			rpc("player_hp")
			rpc("player_bt")
			rpc("player_kill")
			rpc("time",delta)
		pass
	pass
func ui_set():
	rpc("all_ui_set")
	pass
sync func all_ui_set():
	for p_id in players_all:
		hp = get_node("/root/Game/Roof/Player/"+str(p_id)).health
		bullet_amount = get_node("/root/Game/Roof/Player/"+str(p_id)+"/Weapon").BULLET_AMOUNT
		order = connect.select_save_order[int(p_id)]
		shift = 0
		for i in range(hp):
			sprite = Sprite.new()
			sprite.set_texture(heart)
			spawn_pos = get_node("./Heart_Point/Position"+str(order-1)).position
			spawn_pos.x += shift
			if order%2 == 1:shift+=16*2
			else :shift-=16*2
			sprite.position = spawn_pos
			sprite.set_name(str(i))
			sprite.scale = Vector2(2,2)
			get_node("./Heart/P"+str(order)).add_child(sprite)
			pass
		shift = 0
		for i in range(bullet_amount):
			sprite_bullet = Sprite.new()
			sprite_bullet.set_texture(bullet)
			spawn_pos = get_node("./Heart_Point/Position"+str(order-1)).position
			spawn_pos.x += shift
			if order%2 == 1:shift+=16*2
			else :shift-=16*2
			sprite_bullet.position = spawn_pos
			sprite_bullet.position.y += 28 
			sprite_bullet.set_name(str(i))
			sprite_bullet.scale = Vector2(2,2)
			get_node("./Bullet/P"+str(order)).add_child(sprite_bullet)
			pass
		if order%2 == 1:shift+=25
		else :shift-=25
		get_node("./label/Name_P"+str(order)).text = players_all[p_id]
		pass
		start_flag = true
	pass
sync func player_hp():
	for p_id in players_all:
		order = connect.select_save_order[int(p_id)]
		var heart_num
		hp = get_node("/root/Game/Roof/Player/"+str(p_id)).health
		heart_num = get_node("./Heart/P"+str(order)).get_child_count()
		loss_hp = heart_num - hp
		
		while hp < heart_num and heart_num>0:
			get_node("./Heart/P"+str(order)+"/"+str(heart_num-1)).hide()
			heart_num -=1
			pass
		for i in range(hp-loss_hp):
			get_node("./Heart/P"+str(order)+"/"+str(i)).show()
			pass
		pass
	pass
sync func player_bt():
	for p_id in players_all:
		order = connect.select_save_order[int(p_id)]
		var bullet_num
		bullet_amount = get_node("/root/Game/Roof/Player/"+str(p_id)+"/Weapon").BULLET_AMOUNT
		bullet_num = get_node("./Bullet/P"+str(order)).get_child_count()
		var loss_bt = get_node("/root/Game/Roof/Player/"+str(p_id)+"/Weapon").bullet_count
		while bullet_amount-loss_bt < bullet_num and bullet_num>0:
			get_node("./Bullet/P"+str(order)+"/"+str(bullet_num-1)).hide()
			bullet_num -=1
			pass
		for i in range(bullet_amount-loss_bt):
			get_node("./Bullet/P"+str(order)+"/"+str(i)).show()
			pass
		pass
	pass
sync func player_kill():
	for p_id in players_all:
		order = connect.select_save_order[int(p_id)]
		#get_node("./label/Kill_P"+str(order)).text = "kill:"+str(connect.player_kill_num[int(p_id)]/connect.select_save_order.size())
		get_node("./label/Kill_P"+str(order)).text = "kill:"+str(connect.player_kill_num[int(p_id)])
		pass
	pass
sync func time(delta):
	timer += delta
	get_node("./label/time").text = str(floor(timer))
	if(floor(timer)==60):
		print("Game Over")
		rpc("grade")
	pass
sync func grade():#排名程式
	connect.players_all = players_all
	var end = load("res://scene/ending.tscn").instance()
	get_tree().get_root().add_child(end)
	if(get_tree().get_root().get_node("Game")):get_tree().get_root().get_node("Game").queue_free()
	pass
#sync func grade():#排名程式
#	connect.player_kill_num
#	connect.player_die_num
#	connect.player_grade
#	var i = 0
#	for p_id in connect.player_kill_num:
#		connect.player_grade[i] = p_id
#		i +=1
#		pass
#	#--------------------------------------------------------------------排序名次
#	var bubble_flag = true
#	var switch_num
#	while bubble_flag:
#		bubble_flag = false
#		for index in range(connect.select_save_order.size()-1):
#			if connect.player_kill_num[connect.player_grade[index]] < connect.player_kill_num[connect.player_grade[index+1]]:
#				switch_num = connect.player_grade[index]
#				connect.player_grade[index] = connect.player_grade[index+1]
#				connect.player_grade[index+1] = switch_num
#				bubble_flag = true
#				pass
#			if connect.player_kill_num[connect.player_grade[index]] == connect.player_kill_num[connect.player_grade[index+1]]:
#				if connect.player_die_num[connect.player_grade[index]] > connect.player_die_num[connect.player_grade[index+1]]:
#					switch_num = connect.player_grade[index]
#					connect.player_grade[index] = connect.player_grade[index+1]
#					connect.player_grade[index+1] = switch_num
#					bubble_flag = true
#					pass
#				pass
#			pass
#		pass
#	#--------------------------------------------------------------------印出名次
#	for index in range(connect.select_save_order.size()):
#		print("第"+str(index+1)+"名"+str(connect.select_save_order[connect.player_grade[index]])+str(players_all[connect.player_grade[index]])+"")
#		print("Kill:"+str(connect.player_kill_num[connect.player_grade[index]])+"Death:"+str(connect.player_die_num[connect.player_grade[index]]))
#	pass#---------------------------grade END