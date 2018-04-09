extends KinematicBody2D

var angle = 0
#--------------------------------多重輸入判斷
var jflag = 0
#--------------------------------初始
var player = 0 			# 玩家編號
var input_kind = 0 		# 輸入裝置類型，0:KEY 1:JOY
var input_device = 0	# 輸入裝置編號
var health			# 生命值
var MOTION_SPEED	# 移動速度
#--------------------------------動作flag
#--------------------------------死亡機制
var die_flag = false	#死亡旗號
#--------------------------------死亡機制 END
var motion
#--------------------------------動畫
var anim#前
var new_anim#後
var shot_anim#前
var new_shot_anim#後

var fire_anim = false
#---------------------------陷阱部分
var bag_trap = []

#替換背包道具變數S
var bag_trap_switch_num = 0
var e_change_trap_flag = true
var q_change_trap_flag = true
var space_put_trap_flag = true
#替換背包道具變數E
var color_blue_flag = false#控制角色變藍
var color_red_flag = false#控制角色變紅
var color_time = 0#顏色改變時間計數器
var slow_flag = false#控制角色變慢
var slow_time = 0#變慢時間計數器
var reg_speed = 0#用來還原速度
var hide_flag = false#控制角色隱形
var hide_time = 0#隱形時間計數器
var atk_flag = false#控制角色攻擊力增加
var atk_time = 0#攻擊力增加時間計數器
var reg_dmg = 0#用來還原攻擊
var speed_flag = false#控制角色速度增加
var speed_time = 0#速度增加時間計數器
var five_time = 0#5秒時間計數器
#---------------------------陷阱部分 END
#--------------------------------僕玩家移動變數
slave var slave_motion = Vector2()
slave var slave_pos = Vector2()
slave var slave_new_anim
slave var slave_angle = 0#僕角度
slave var slave_shot_anim#前
slave var slave_new_shoot_anim#後
slave var slave_bag_trap_switch_num = 0#僕背包道具變數
slave var slave_space_put_trap_flag =false#僕使用物品
slave var slave_bag_trap_use_num = 0#僕背包道具使用變數
slave var slave_die_flag = false#僕死亡旗號
#--------------------------------以上變數區
func _ready():
	MOTION_SPEED = get_node("./Init_data").MOTION_SPEED
	reg_speed = get_node("./Init_data").MOTION_SPEED
	reg_dmg = get_node("/root/Game/Roof/Player/"+get_name()+"/Weapon").BULLET_DMG
	health = get_node("./Init_data").health
	if (is_network_master()):
		get_node("/root/Game/Camera/Camera2D").set_master(self.get_name())
	slave_new_anim = new_anim
	slave_pos = position
	slave_new_shoot_anim = new_shot_anim
	get_node("Weapon").connect("bullet_shot", self, "fire_anim")#連接Weapon生成子彈的訊號
	get_node("AP").connect("animation_finished", self, "anim_fin")#連接射擊動作做完的訊號
	get_node("AP").connect("animation_changed", self, "anim_fin")#連接射擊動作做完的訊號
	#get_node("/root/Game/Camera/Camera2D/UI").ui_set(get_name())
func _physics_process(delta):
#-----------------------------------------------輸入狀態
	var shooting
	shooting = Input.is_joy_button_pressed ( input_device, 7 )
	shooting = Input.is_action_pressed("shoot")
	
	var reload
	reload = Input.is_joy_button_pressed ( input_device, 1 )
	reload = Input.is_action_pressed("reload")
	
	if ( not jflag ): 
		angle=-atan2((get_global_mouse_position().x -  get_position().x),(get_global_mouse_position().y -  get_position().y))*180/PI
	if (Input.get_joy_axis(input_device, 3)<-0.3||Input.get_joy_axis(input_device, 3)> 0.3
			||Input.get_joy_axis(input_device, 2)<-0.3||Input.get_joy_axis(input_device, 2)> 0.3):
		jflag = 1
		angle = -atan2(Input.get_joy_axis(input_device, JOY_AXIS_2), Input.get_joy_axis(input_device,JOY_AXIS_3))*180/PI
#-----------------------------------------------移動	
	motion = Vector2()
	#----------------------------------------------------移動部分
	if (is_network_master()):#------------------判斷是否是主人
		#if (input_kind):#---------------joystick
		if (Input.get_joy_axis(input_device, 1)<-0.3): # up
			motion += Vector2(0, Input.get_joy_axis(input_device, 1))
			new_anim = "walk_back"
		if (Input.get_joy_axis(input_device, 1)> 0.3): #down
			motion += Vector2(0, Input.get_joy_axis(input_device, 1))
			new_anim = "walk_front"
		if (Input.get_joy_axis(input_device, 0)<-0.3): #left
			motion += Vector2(Input.get_joy_axis(input_device, 0), 0)
			new_anim = "walk_left"
		if (Input.get_joy_axis(input_device, 0)> 0.3): #right
			motion += Vector2(Input.get_joy_axis(input_device, 0), 0)
			new_anim = "walk_right"
		#else:#--------------------------keyboard
		if (Input.is_action_pressed("up")):
			motion += Vector2(0, -1)
		if (Input.is_action_pressed("down")):
			motion += Vector2(0, 1)
		if (Input.is_action_pressed("left")):
			motion += Vector2(-1, 0)
		if (Input.is_action_pressed("right")):
				motion += Vector2(1, 0)
		if (Input.is_action_pressed("fire")):
			get_node("Weapon").rpc("fire", (angle*PI/180 + PI/2), get_node("hand/gun/shotform").get_global_transform().get_origin()-self.position)
			
		if (Input.is_action_just_released("fire")):
			get_node("Weapon").rpc("release")
		if (Input.is_action_pressed("reload")):
			get_node("Weapon").rpc("charge")
#		
		#-------------------------------------------------------------陷阱主人區塊start
		#-----------------------------------------------切換與放置陷阱
		if Input.is_action_pressed("e_change_trap"):
			if e_change_trap_flag :
				e_change_trap_flag = false
				if bag_trap.size():
					if bag_trap_switch_num :
						get_node("../../Trap/"+str(bag_trap[bag_trap_switch_num-1])).position = get_node("../../Trap_Point/trash").position
					bag_trap_switch_num = (bag_trap_switch_num+1)%(bag_trap.size()+1)
					if bag_trap_switch_num :
						get_node("../../Trap/"+str(bag_trap[bag_trap_switch_num-1])).position = self.position + Vector2(0, 10)
						#get_node("../../Trap/"+str(bag_trap[bag_trap_switch_num-1])+"/Sprite").modulate.a = 0.5
		if Input.is_action_pressed("q_change_trap"):
			if q_change_trap_flag :
				q_change_trap_flag = !q_change_trap_flag
				if bag_trap.size():
					if bag_trap_switch_num :
						get_node("../../Trap/"+str(bag_trap[bag_trap_switch_num-1])).position = get_node("../../Trap_Point/trash").position
						
					bag_trap_switch_num = bag_trap_switch_num-1
					if bag_trap_switch_num < 0 :bag_trap_switch_num = bag_trap.size()
					if bag_trap_switch_num :
						get_node("../../Trap/"+str(bag_trap[bag_trap_switch_num-1])).position = self.position + Vector2(0, 10)
						#get_node("../../Trap/"+str(bag_trap[bag_trap_switch_num-1])+"/Sprite").modulate.a = 0.5
	#控制陷阱持續跟著使用者
		if bag_trap_switch_num :
			get_node("../../Trap/"+str(bag_trap[bag_trap_switch_num-1])).position = self.position + Vector2(0, 10)			
		if Input.is_action_pressed("space_put_trap"):
			test_shader()
			if space_put_trap_flag :
				space_put_trap_flag = false
				if bag_trap_switch_num :
					#rset("slave_bag_trap_switch_num", bag_trap_switch_num)
					rset("slave_bag_trap_use_num", bag_trap_switch_num)
					rset("slave_space_put_trap_flag", true)
					
					get_node("../../Trap/"+str(bag_trap[bag_trap_switch_num-1])).position = self.position			
					get_node("../../Trap/"+str(bag_trap[bag_trap_switch_num-1])).modulate.a = 1
					get_node("../../Trap/"+str(bag_trap[bag_trap_switch_num-1])).trap_use_flag = true
					print(bag_trap)
					bag_trap.remove(bag_trap_switch_num-1)
					print(bag_trap)
				bag_trap_switch_num = 0
		if not Input.is_action_pressed("e_change_trap"):
			e_change_trap_flag = true
		if not Input.is_action_pressed("q_change_trap"):
			q_change_trap_flag = true
		if not Input.is_action_pressed("space_put_trap"):
			space_put_trap_flag = true
		#-----------------------------------------------切換與放置陷阱 END
		#--------------------------------------------陷阱主人區塊 END
		rset("slave_angle", angle)
		rset("slave_motion", motion)
		rset("slave_pos", self.position)#將自己位置更新給分身（slave）
		rset("slave_new_anim", new_anim)
		rset("slave_new_shoot_anim", new_shot_anim)
		rset("slave_bag_trap_switch_num", bag_trap_switch_num)
	#--------------------------------------------判斷是否是主人 END
	else:#---------------------------------------是僕人端
		position = slave_pos
		motion = slave_motion
		new_anim = slave_new_anim
		angle = slave_angle
		new_shot_anim = slave_new_shoot_anim
		#旋轉槍枝
		get_node("hand").rotation = (angle+90)*PI/180
		print(angle)
		#控制陷阱持續跟著使用者
		if not bag_trap_switch_num == slave_bag_trap_switch_num && not bag_trap_switch_num == 0:
			if  bag_trap.size() > 0 and bag_trap.size() >= bag_trap_switch_num:
				get_node("../../Trap/"+str(bag_trap[bag_trap_switch_num-1])).position = get_node("../../Trap_Point/trash").position
			else: print("trap size not fit")
		#控制陷阱持續跟著使用者 END
		
		#使用陷阱
		if slave_space_put_trap_flag:
			slave_space_put_trap_flag = false
			get_node("../../Trap/"+str(bag_trap[slave_bag_trap_use_num-1])).position = self.position			
			get_node("../../Trap/"+str(bag_trap[slave_bag_trap_use_num-1])).modulate.a = 1
			get_node("../../Trap/"+str(bag_trap[slave_bag_trap_use_num-1])).trap_use_flag = true
			print(bag_trap)
			bag_trap.remove(slave_bag_trap_use_num-1)
			print(bag_trap)
			slave_bag_trap_use_num = 0
			bag_trap_switch_num = 0
		#使用陷阱 END
		#if not slave_space_put_trap_flag: 
		bag_trap_switch_num = slave_bag_trap_switch_num
		if bag_trap_switch_num : #預覽道具，跟隨
			if  bag_trap.size() > 0 and bag_trap.size() >= bag_trap_switch_num:
				get_node("../../Trap/"+str(bag_trap[bag_trap_switch_num-1])).position = self.position + Vector2(0, 10)	
			else: print("trap size not fit")

#--------------------------------------------是僕人端END
	if (not is_network_master()):
		slave_pos = position # To avoid jitter
	#-------------------------------------------------------------移動
	motion = motion.normalized()*MOTION_SPEED*delta
	move_and_slide(motion)	
#-----------------------------------------------動畫
	if (new_anim != anim):
		anim = new_anim
		get_node("AP").play(anim)
	if (new_shot_anim != shot_anim):
		shot_anim = new_anim
		get_node("AP").play(shot_anim)
	if(fire_anim):
			get_node("AP2").play("gun_attack")
			get_node("sound").playing = true
			fire_anim = false
	#--------------------------------------------動畫
		
	if(angle>0): 
		get_node("hand/gun").flip_v = 1
	else: 
		get_node("hand/gun").flip_v = 0
	#get_node("hand").set_rotation_in_degrees(angle+90)
	get_node("hand").rotation = (angle+90)*PI/180
	get_node("hand/gun").z_index = z_index + 1#----------------------------------------------------18/3/5
	if(motion.length()<=0):
		if(abs(angle)>120):
			new_anim = "stop_back"
			get_node("hand/gun").z_index = z_index - 1
		if(angle>60 and angle<121):new_anim = "stop_left"
		if(angle<-60 and angle>-121):new_anim = "stop_right"
		if(abs(angle)<60):new_anim = "stop_front"
	else:
		if(abs(angle)>120):
			new_anim = "walk_back"
			get_node("hand/gun").z_index = z_index - 1
		if(angle>60 and angle<121):new_anim = "walk_left"
		if(angle<-60 and angle>-121):new_anim = "walk_right"
		if(abs(angle)<60):new_anim = "walk_front"
	#---------------------------------------------陷阱效果 start
	if color_red_flag:color_red(delta)
	if color_blue_flag:color_blue(delta)
	if slow_flag:slow_trap(delta)
	if hide_flag:hide_trap(delta)
	if atk_flag:atk_trap(delta)
	if speed_flag:speed_trap(delta)
	
	#---------------------------------------------陷阱效果 end

func set_player_name(name):
	pass
func fire_anim():
	fire_anim = true
func anim_fin(anim):#呼叫時會把結束的動畫傳進來
	fire_anim = false
#---------------------------------------------陷阱效果函式 start
func color_blue(delta):
	if color_red_flag:
		color_red_flag = false
		color_time = 0
	color_time += delta
	if color_time > 0.5:
		color_blue_flag = false
		color_time = 0
		self.set_modulate(Color(1.0,1.0,1.0))
	else:
		self.set_modulate(Color(1.0,1.0,255/(510*color_time)))
	pass
func color_red(delta):
	if color_blue_flag:
		color_blue_flag = false
		color_time = 0
	color_time += delta
	if color_time > 0.5:
		color_red_flag = false
		color_time = 0
		self.set_modulate(Color(1.0,1.0,1.0))
	else:
		self.set_modulate(Color(255/(510*color_time),1.0,1.0))
	pass
func slow_trap(delta):
	if slow_time > 3.0:
		MOTION_SPEED = reg_speed
		slow_flag = false
		slow_time = 0
	elif slow_time == 0 :
		MOTION_SPEED = MOTION_SPEED/2
		slow_time += delta
	else:
		slow_time += delta
	pass
func hide_trap(delta):
	hide_time += delta
	if hide_time > 5:
		hide_flag = false
		hide_time = 0
		self.set_modulate(Color(1.0,1.0,1.0,1.0))
	else:
		if (is_network_master()):
			self.set_modulate(Color(1.0,1.0,1.0,0.6))
		else:
			self.set_modulate(Color(1.0,1.0,1.0,0.1))
	pass
func atk_trap(delta):
	if atk_time > 10.0:
		get_node("/root/Game/Roof/Player/"+get_name()+"/Weapon").BULLET_DMG = reg_dmg
		atk_flag = false
		atk_time = 0
	elif atk_time == 0 :
		get_node("/root/Game/Roof/Player/"+get_name()+"/Weapon").BULLET_DMG *=2
		atk_time += delta
	else:
		atk_time += delta
	pass
func speed_trap(delta):
	if speed_time > 5.0:
		MOTION_SPEED = reg_speed
		speed_flag = false
		speed_time = 0
	elif speed_time == 0 :
		MOTION_SPEED = MOTION_SPEED*1.2
		#get_node("/root/Game/Camera/Camera2D").mirage()
		if (is_network_master()):
			get_node("/root/Game/Camera/Camera2D").mirage_time_control=30
			get_node("/root/Game/Camera/Camera2D").mirage_flag=true
		speed_time += delta
	else:
		speed_time += delta
	pass
	pass
#---------------------------------------------陷阱效果函式 end
func hurt(dmg,ower = ''):
	if not die_flag:
		health -= dmg
		get_node("hurt").emitting = true
		if (is_network_master()):
			get_node("/root/Game/Camera/Camera2D").shake()
		if health <=0:
			die_flag = true
			rpc("die",get_name(),ower)
			pass
		pass
	#----------------------------------------道具效果受擊中斷 Start
		if hide_flag:hide_time = hide_time+5
		#----------------------------------------道具效果受擊中斷 End
		color_red_flag = true#因為兩邊都要看到受擊變色，所以不放入is_network_master中				
	pass
	

#---------------------------------------------死亡機制
sync func die(dead,killer):
	connect.player_die_num[int(dead)] += 1
	if dead != killer:
		connect.player_kill_num[int(killer)] += 1
	rpc("reset_player",dead)
	pass
var f = true
func test_shader():
	#get_node("/root/Game/Camera/Camera2D").mirage_time_control=10
	#get_node("/root/Game/Camera/Camera2D").mirage_flag=true
	pass
sync func reset_player(pid):
	get_node("/root/Game/Roof/Player/"+str(pid)).health = get_node("/root/Game/Roof/Player/"+str(pid)+"/Init_data").health
	get_node("/root/Game/Roof/Player/"+str(pid)).position = get_node("/root/Game/Roof/Player_Point/Position"+str(int(connect.select_save_order[int(pid)])-1)).position
	get_node("/root/Game/Roof/Player/"+str(pid)).die_flag = false
	get_node("/root/Game/Roof/Player/"+str(pid)+"/Weapon").bullet_count = 0
	pass