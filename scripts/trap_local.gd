extends Area2D
#-------------------------------陷阱效果數值START
var soda_add_hp = 1#加料汽水加值
var beer_add_hp = 1#染色啤酒加值
#-------------------------------陷阱效果數值 END
var get_body_save = null#儲存是誰得到此陷阱
var trap_use_flag = false#使用陷阱
var trap_recover = false#準備還原陷阱
var trap_type = 0#是哪種的陷阱，影響日後陷阱效果
var point_index = 0#生成點陣列的編號
var pre_trap_recover_time = 1#陷阱還原所需時間
var recover_timer = 0#陷阱還原所需時間計數器
#0,加料汽水 1嘔吐物


var image1 = load("res://image/GameScene/traps1.png")#加料汽水(trap1)圖
var image2 = load("res://image/GameScene/traps3.png")#派對帽子圖
var image3 = load("res://image/GameScene/traps2.png")#染色啤酒圖
var image4 = load("res://image/GameScene/traps4.png")#天然草藥圖
var image5 = load("res://image/GameScene/traps6.png")#超級雞尾酒圖
var image6 = load("res://image/GameScene/traps5.png")#嘔吐物圖

func _ready():
	point_index = get_node("../").generate_points_num[int(self.get_name())]
	#用來日後調控陷阱出場順序用
	if self.get_name() == "0":
		trap_type = 0#加料汽水
	if self.get_name() == "1":
		trap_type = 1#嘔吐物
	if self.get_name() == "2":	
		trap_type = 2#天然草藥
		
	if trap_type == 0:
		self.get_child(0).set_texture(image1)#加料汽水
	if trap_type == 1:#----------------嘔吐物
		self.get_child(0).set_texture(image6)
	if trap_type == 2:#天然草藥
		self.get_child(0).set_texture(image4)
		
	connect("body_entered", self, "_on_trap_area_body_enter")#start signal
	connect("body_exited", self, "_on_trap_body_exit")#start signal
	pass

func _process(delta):
	right_now_use()
	recover(delta)
	pass
func _on_trap_area_body_enter(body):
	#如果沒有人取得，儲存取得者
	if get_body_save == null :
		if body.get_class() == 'KinematicBody2D':#判斷是不是player
			trap_get(body)
	#------------------------------------------------陷阱被放置了，開啟狀態
	if trap_use_flag:
		if body.get_class() == 'KinematicBody2D':#判斷是不是player
			trap_use(body)
	pass
func trap_get(body):
	get_body_save = body
	self.position = get_node("../../Trap_Point/trash").position
	self.modulate.a = 0.5
	get_body_save.bag_trap.append(self.get_name())
	var points_num = get_node("../").generate_points_num
	for index in range(points_num.size()):
		if points_num[index] == point_index:
			get_node("../").generate_points_num.remove(index)
			break
	pass

func right_now_use():
	if trap_use_flag:
		if trap_type == 0:#加料汽水效果
			trap_use(get_body_save)
			pass
	pass 
func trap_use(body):
	trap_use_flag = false
	if trap_type == 0:#加料汽水
		body.addHP(soda_add_hp)
		pass
	elif trap_type == 1:#嘔吐物
		body.hurt(1)
		body.slow()
		pass
	elif trap_type == 2:#天然草藥
		body.attackUP()
		pass
	self.position = get_node("../../Trap_Point/trash").position
	get_body_save = null
	trap_recover = true
	pass
func recover(delta):
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
				for index in range(get_node("../").generate_points_num.size()):
					if(get_node("../").generate_points_num[index] == random_num):
						randomize()
						random_num = str( randi()%get_node("../").Trap_spwan_num )
						random_num_flag = true
						break
				if random_num_flag == false : break
			get_node("../").generate_points_num.append( random_num )
			#用來計算不重複位址的random_num END
			point_index = str(random_num)#紀錄自己位址用
			self.position = get_node("../../Trap_Point/Position"+random_num).position
	pass