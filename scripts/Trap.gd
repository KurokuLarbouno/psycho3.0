extends Area2D
#-------------------------------陷阱效果數值START
var soda_add_hp = 1#加料汽水加值
var beer_add_hp = 1#染色啤酒加值
#-------------------------------陷阱效果數值 END
var get_body_save = ''#儲存是誰得到此陷阱
#嘔吐物
var image = load("res://image/GameScene/traps1.png")#加料汽水(trap1)圖
var image2 = load("res://image/GameScene/traps3.png")#派對帽子圖
var image3 = load("res://image/GameScene/traps2.png")#染色啤酒圖
var image4 = load("res://image/GameScene/traps4.png")#天然草藥圖
var image5 = load("res://image/GameScene/traps6.png")#超級雞尾酒圖
var image6 = load("res://image/GameScene/traps5.png")#嘔吐物圖
var trap_type = 0#是哪種的陷阱，影響日後陷阱效果
var trap_use_flag = false#使用陷阱
var trap_recover = false#準備還原陷阱
var pre_trap_recover_time = 1#陷阱還原所需時間
var recover_timer = 0#陷阱還原所需時間計數器
var point_index = 0#生成點陣列的編號
var trap_body#暫存陷阱本身以傳出
var trap_pos#用來存陷阱位置
#slave var slave_get_body_save



func _ready():
	point_index = connect.generate_points_num[int(self.get_name())]
	if self.get_name() == "0":
		self.get_child(0).set_texture(image)#加料汽水
		trap_type = 0
	if self.get_name() == "1":#----------------嘔吐物
		self.get_child(0).set_texture(image6)
		trap_type = 1
	if self.get_name() == "2":
		self.get_child(0).set_texture(image2)#派對帽子
		trap_type = 2
	if self.get_name() == "3":
		self.get_child(0).set_texture(image3)#染色啤酒
		trap_type = 3
	if self.get_name() == "4":
		self.get_child(0).set_texture(image4)#天然草藥
		trap_type = 4
	if self.get_name() == "5":
		self.get_child(0).set_texture(image5)#超級雞尾酒圖
		trap_type = 5
	if self.get_name() == "6":
		self.get_child(0).set_texture(image6)
		trap_type = 6
	if self.get_name() == "7":
		self.get_child(0).set_texture(image6)
		trap_type = 7
	if self.get_name() == "8":
		self.get_child(0).set_texture(image6)
		trap_type = 8
	if self.get_name() == "9":
		self.get_child(0).set_texture(image6)
		trap_type = 9
	connect("body_entered", self, "_on_trap_area_body_enter")#start signal
	connect("body_exited", self, "_on_trap_body_exit")#start signal
	pass
	
func _on_trap_area_body_enter(body):
	if get_tree().is_network_server():
		#如果沒有人取得，儲存取得者
		if get_body_save == '' :
			if body.get_class() == 'KinematicBody2D':#判斷是不是ID
				rpc("trap_get",body.get_name())
		#------------------------------------------------陷阱被放置了，開啟狀態
		if trap_use_flag:
			if body.get_class() == 'KinematicBody2D':#判斷是不是ID
				rpc("trap_use",body.get_name())
	pass
func _on_trap_body_exit(body):
	pass
	
func _physics_process(delta):
	if (is_network_master()):#------------------判斷是否是主人
		1
	else:
		1
#-------------------------------控制立即使用性的道具 START
	if trap_use_flag:
		if get_tree().is_network_server():
			if self.get_name() == "0":#加料汽水效果
				rpc("trap_use",get_body_save)
				pass
			if self.get_name() == "2":#派對帽子效果
				rpc("trap_use",get_body_save)
				pass
			if self.get_name() == "3":#染色啤酒
				rpc("trap_use",get_body_save)
				pass
			if self.get_name() == "4":#天然草藥效果
				rpc("trap_use",get_body_save)
				pass
			if self.get_name() == "5":#超級雞尾酒效果
				rpc("trap_use",get_body_save)
				pass
#-------------------------------控制立即使用性的道具 END
	if trap_recover :
		recover_timer += delta
		#---------------------------------------用以讓陷阱同步重新回到場上
		if(recover_timer > pre_trap_recover_time):
			recover_timer = 0
			trap_recover = false
			#用來計算不重複位址的random_num
			var random_num_flag = false
			randomize()
			var random_num = str(randi()%connect.Trap_spwan_num)
			while 1:
				random_num_flag = false
				for index in range(connect.generate_points_num.size()):
					if(connect.generate_points_num[index] == random_num):
						randomize()
						random_num = str( randi()%connect.Trap_spwan_num )
						random_num_flag = true
						break
				if random_num_flag == false : break
			connect.generate_points_num.append( random_num )
			#用來計算不重複位址的random_num END
			point_index = str(random_num)#紀錄自己位址用
			#self.position = get_node("../../Trap_Point/Position"+random_num).position
			if get_tree().is_network_server():
				trap_pos = get_node("../../Trap_Point/Position"+random_num).position
				rpc("trap_recover",get_name(),trap_pos)
		#---------------------------------------用以讓陷阱同步重新回到場上 END
	pass
sync func trap_recover(name,pos):#用以讓陷阱同步重新回到場上

	#get_body_save = ''
	trap_body = get_node("../"+get_name())
	trap_body.position = pos
	trap_body.modulate.a = 1
	pass
sync func trap_get(name):#用以讓陷阱同步重新回到場上
	get_body_save = name
	print("trap_get "+str(trap_type)+"name:"+name)
	self.position = get_node("../../Trap_Point/trash").position
	self.modulate.a = 0.5
	get_node("../../Player/"+name).bag_trap.append(trap_type)
	for index in range(connect.generate_points_num.size()):
		if connect.generate_points_num[index] == point_index:
			connect.generate_points_num.remove(index)
			break
	pass
sync func trap_use(name):#使用道具
	trap_use_flag = false
	print("trap_use "+str(trap_type)+"name:"+name)
#-------------------------------------------------各種道具效果
	if self.get_name() == "0":
		var hp
		var init_hp
		
		get_node("../../Player/"+name).color_blue_flag = true
		get_node("../../Player/"+name).color_time = 0
		hp = get_node("../../Player/"+name).health
		init_hp= get_node("../../Player/"+name+"/Init_data").health
		hp = hp+beer_add_hp
		if hp > init_hp:hp = init_hp
		get_node("../../Player/"+name).health = hp
	if self.get_name() == "1":#緩速陷阱效果
		get_node("../../Player/"+name).color_time = 0
		get_node("../../Player/"+name).color_red_flag = true
		get_node("../../Player/"+name).slow_flag = true
		get_node("../../Player/"+name).slow_time = 0
		get_node("../../Player/"+name).hurt(1,get_body_save)
	if self.get_name() == "2":#派對帽子效果
		get_node("../../Player/"+name).color_time = 0
		get_node("../../Player/"+name).color_blue_flag = true
		
		get_node("../../Player/"+name).hide_flag = true
		get_node("../../Player/"+name).hide_time = 0
	if self.get_name() == "3":#染色啤酒
		var hp
		var init_hp
		get_node("../../Player/"+name).color_time = 0
		get_node("../../Player/"+name).color_blue_flag = true
		
		hp = get_node("../../Player/"+name).health
		init_hp= get_node("../../Player/"+name+"/Init_data").health
		hp = hp+soda_add_hp
		if hp > init_hp:hp = init_hp
		get_node("../../Player/"+name).health = hp
		get_node("../../Player/"+name).atk_flag = true
		get_node("../../Player/"+name).atk_time = 0
	if self.get_name() == "4":#天然草藥
		get_node("../../Player/"+name).color_time = 0
		get_node("../../Player/"+name).color_blue_flag = true
		
		get_node("../../Player/"+name).atk_time = 0
		get_node("../../Player/"+name).atk_flag = true
		
		get_node("../../Player/"+name).speed_time = 0
		get_node("../../Player/"+name).speed_flag = true
		
		get_node("../../Player/"+name).speed_time = 0
		get_node("../../Player/"+name).speed_flag = true
	if self.get_name() == "5":#超級雞尾酒
		get_node("../../Player/"+name).color_time = 0
		get_node("../../Player/"+name).color_blue_flag = true
		
		get_node("../../Player/"+name).speed_time = 0
		get_node("../../Player/"+name).speed_flag = true
	if self.get_name() == "6":
		get_node("../../Player/"+name).color_time = 0
		get_node("../../Player/"+name).color_blue_flag = true

	if self.get_name() == "7":
		get_node("../../Player/"+name).color_time = 0
		get_node("../../Player/"+name).color_blue_flag = true

	if self.get_name() == "8":
		get_node("../../Player/"+name).color_time = 0
		get_node("../../Player/"+name).color_blue_flag = true

	if self.get_name() == "9":
		get_node("../../Player/"+name).color_time = 0
		get_node("../../Player/"+name).color_blue_flag = true


#-------------------------------------------------各種道具效果 END
	self.position = get_node("../../Trap_Point/trash").position
	#get_body_save = str(int(get_body_save)+1)
	get_body_save = ''
	trap_recover = true
	pass