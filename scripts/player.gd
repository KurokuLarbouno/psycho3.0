extends KinematicBody2D
#傳直給UI
signal set_health
signal set_bullet
signal update_health
signal update_bullet

#--------------------------------多重輸入判斷
var jflag = 0

var angle = 0

var player_num = 0 			# 玩家編號
var input_device = 0	# 輸入裝置編號
var health = 20			# 生命值
var RHP					#用來還原的生命值
var clip = 0			#彈夾
var MOTION_SPEED = 8000	# 移動速度
var player_type = 0
var motion
var die = false
var freeze = true

var player_state = 0 # 0 出生(無敵); 1 一般; 2 死亡; 3 待機(不能控制)

var anim#前
var new_anim#後
var shot_anim#前
var new_shot_anim#後
var fire_anim = false

#---------------------------陷阱部分
var bag_trap = []
var e_change_trap_flag = true
var q_change_trap_flag = true
var space_put_trap_flag = true
var bag_trap_switch_num = 0

var c1_img = load("res://image/Character/ctest1_walk.png")
var c2_img = load("res://image/Character/ctest2_walk.png")
var c3_img = load("res://image/Character/ctest3_walk.png")
var c4_img = load("res://image/Character/ctest4_walk.png")
var c1_gun = load("res://image/Character/ctest1_gun.png")
var c2_gun = load("res://image/Character/ctest2_gun.png")
var c3_gun = load("res://image/Character/ctest3_gun.png")
var c4_gun = load("res://image/Character/ctest4_gun.png")

func _ready():
	#設定角色圖
	if(player_type == 0):
		$main.texture = c1_img
		$hand/gun.texture = c1_gun
	elif(player_type == 1):
		$main.texture = c2_img
		$hand/gun.texture = c2_gun
	elif(player_type == 2):
		$main.texture = c3_img
		$hand/gun.texture = c3_gun
	elif(player_type == 3):
		$main.texture = c4_img
		$hand/gun.texture = c4_gun
	RHP = health
	$Weapon.connect("bullet_shot", self, "fire_anim")#連接Weapon生成子彈的訊號
	$Weapon.connect("bullet_reload", self, "_bullet_reload")#連接Weapon生成子彈的訊號
	pass

func _process(delta):
	if(player_state == 0): #freeze
		#do something
		if(!freeze):
			player_state = 1
	elif(player_state == 1): #活著的時候
		if(freeze):
			player_state = 0
		player_move(delta)	
		play_anim()
		player_fire()
		player_trap_switch()
		if(die == true):
			player_state = 2
	elif(player_state == 2):
		player_state = 0
	pass
func player_move(delta):
	motion = Vector2()
	if(input_device < 4): #搖桿
		if (Input.get_joy_axis(input_device, 1)<-0.3): # up
			motion += Vector2(0, Input.get_joy_axis(input_device, 1))
		if (Input.get_joy_axis(input_device, 1)> 0.3): #down
			motion += Vector2(0, Input.get_joy_axis(input_device, 1))
		if (Input.get_joy_axis(input_device, 0)<-0.3): #left
			motion += Vector2(Input.get_joy_axis(input_device, 0), 0)
		if (Input.get_joy_axis(input_device, 0)> 0.3): #right
			motion += Vector2(Input.get_joy_axis(input_device, 0), 0)
	elif(input_device == 4): #鍵盤
		if (Input.is_action_pressed("up")):
			motion += Vector2(0, -1)
		if (Input.is_action_pressed("down")):
			motion += Vector2(0, 1)
		if (Input.is_action_pressed("left")):
			motion += Vector2(-1, 0)
		if (Input.is_action_pressed("right")):
			motion += Vector2(1, 0)
	motion = motion.normalized()*MOTION_SPEED*delta
	move_and_slide(motion)
	pass
func play_anim():
	if ( not jflag ): 
		angle=-atan2((get_global_mouse_position().x -  get_position().x),(get_global_mouse_position().y -  get_position().y))*180/PI
	if (Input.get_joy_axis(input_device, 3)<-0.3||Input.get_joy_axis(input_device, 3)> 0.3
			||Input.get_joy_axis(input_device, 2)<-0.3||Input.get_joy_axis(input_device, 2)> 0.3):
		jflag = 1
		angle = -atan2(Input.get_joy_axis(input_device, JOY_AXIS_2), Input.get_joy_axis(input_device,JOY_AXIS_3))*180/PI
	if (new_anim != anim):
		anim = new_anim
		$animation.play(anim)
	if (new_shot_anim != shot_anim):
		shot_anim = new_anim
		$animation.play(shot_anim)
	if(fire_anim):
		$animation.play("gun_attack")
		$sound.playing = true
		fire_anim = false
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
	pass
func player_fire():
	if(input_device < 4): #搖桿
		if (Input.is_joy_button_pressed(input_device, 7)):#RT
			$Weapon.fire((angle*PI/180 + PI/2),$hand/gun/shotfrom.get_global_transform().get_origin()-self.position)
		elif($Weapon.state == 1):
			$Weapon.release()
		if (Input.is_joy_button_pressed(input_device, 5)):#RB
			$Weapon.charge()
	elif(input_device == 4): #鍵盤
		if (Input.is_action_pressed("fire")):
			$Weapon.fire((angle*PI/180 + PI/2),$hand/gun/shotfrom.get_global_transform().get_origin()-self.position)
		if (Input.is_action_just_released("fire")):
			$Weapon.release()
		if (Input.is_action_pressed("reload")):
			$Weapon.charge()
	pass
func hurt(dmg,ower = ''):
	if not die:
		health -= dmg
		emit_signal("update_health", health)
		get_node("hurt").emitting = true
	#	get_node("/root/Game/Camera/Camera2D").shake()
		if health <=0:
			player_die(ower)
			pass
		pass
	#----------------------------------------道具效果受擊中斷 Start
		#if hide_flag:hide_time = hide_time+5
		#----------------------------------------道具效果受擊中斷 End
		#color_red_flag = true#因為兩邊都要看到受擊變色，所以不放入is_network_master中				
	pass
func player_trap_switch():
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
	#控制陷阱持續跟著使用者
	if bag_trap_switch_num :
		get_node("../../Trap/"+str(bag_trap[bag_trap_switch_num-1])).position = self.position + Vector2(0, 10)			
	if Input.is_action_pressed("space_put_trap"):
		if space_put_trap_flag :
			space_put_trap_flag = false
			if bag_trap_switch_num :
				get_node("../../Trap/"+str(bag_trap[bag_trap_switch_num-1])).position = self.position+ Vector2(0, 10)			
				get_node("../../Trap/"+str(bag_trap[bag_trap_switch_num-1])).modulate.a = 1
				get_node("../../Trap/"+str(bag_trap[bag_trap_switch_num-1])).trap_use_flag = true
				bag_trap.remove(bag_trap_switch_num-1)
			bag_trap_switch_num = 0
	
	if not Input.is_action_pressed("e_change_trap"):
			e_change_trap_flag = true
	if not Input.is_action_pressed("q_change_trap"):
		q_change_trap_flag = true
	if not Input.is_action_pressed("space_put_trap"):
		space_put_trap_flag = true
	pass
func fire_anim():
	#hurt(1)#-------------------------for test!!
	clip -= 1
	emit_signal("update_bullet", clip)
	fire_anim = true

func respawn():
	get_node("./").position = get_node("../../Player_Point/Position" + str(player_num+1)).get_position()
	clip = $Weapon.BULLET_AMOUNT
	health = RHP
	emit_signal("update_bullet", clip)
	emit_signal("update_health", health)
	die = false
	pass
func player_die(killer):
	die = true
	respawn()
	pass
func _bullet_reload():
	clip = $Weapon.BULLET_AMOUNT
	emit_signal("update_bullet", clip)
	pass
func int_ui():
		#初始化UI
	emit_signal("set_health", health)
	emit_signal("set_bullet", $Weapon.BULLET_AMOUNT)
	clip = $Weapon.BULLET_AMOUNT
	pass
func setFreeze(i):
	freeze = i
	
#陷阱效果
func addHP(add_hp):
	health += add_hp
	if health>RHP:
		health = RHP
	emit_signal("update_health", health)
	pass